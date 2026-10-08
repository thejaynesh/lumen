import { readFile } from 'node:fs/promises';
import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import {
  collection, deleteDoc, doc, documentId, getDoc, getDocs, query, where, orderBy, setDoc,
  updateDoc, writeBatch, runTransaction, serverTimestamp, Timestamp,
} from 'firebase/firestore';

const projectId = 'demo-lumen';
let env;
const admin = () => env.authenticatedContext('owner', { email: 'thejaynesh@gmail.com', email_verified: true }).firestore();
const visitor = () => env.unauthenticatedContext().firestore();
const now = Timestamp.fromMillis(Date.now());
const future = Timestamp.fromMillis(Date.now() + 86400000);
const past = Timestamp.fromMillis(Date.now() - 86400000);
const project = (extra = {}) => ({
  title: 'Project', category: 'Web', description: 'A description', techStack: ['Dart'],
  order: 0, isActive: true, createdAt: now, updatedAt: now, ...extra,
});
const job = (slug = 'share', extra = {}) => ({
  slug, title: 'Private title', company: 'Private company', description: 'Private notes',
  projectIds: ['project'], experienceIds: [], customTagline: null, customAbout: 'Public bio',
  isActive: true, viewCount: 0, createdAt: now, updatedAt: now, expiresAt: null, ...extra,
});
const projection = (record) => Object.fromEntries([
  'slug', 'projectIds', 'experienceIds', 'customTagline', 'customAbout',
  'isActive', 'createdAt', 'updatedAt', 'expiresAt',
].map((key) => [key, record[key]]));

async function seed(data) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    const batch = writeBatch(db);
    for (const [path, value] of Object.entries(data)) batch.set(doc(db, path), value);
    await batch.commit();
  });
}

function publish(db, id, record) {
  const batch = writeBatch(db);
  batch.set(doc(db, `jobs/${id}`), record);
  batch.set(doc(db, `profileSlugs/${record.slug}`), { jobId: id });
  batch.set(doc(db, `publicProfiles/${record.slug}`), projection(record));
  return batch.commit();
}

before(async () => {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080').split(':');
  if (!['127.0.0.1', 'localhost', '::1'].includes(host)) throw new Error('Tests only run against a local emulator.');
  env = await initializeTestEnvironment({
    projectId,
    firestore: { host, port: Number(port), rules: await readFile(new URL('../../firestore.rules', import.meta.url), 'utf8') },
  });
});
beforeEach(async () => { await env.clearFirestore(); });
after(async () => { await env?.cleanup(); });

test('anonymous and ordinary users cannot enumerate or read private applications', async () => {
  await seed({ 'jobs/job': job(), 'profileSlugs/share': { jobId: 'job' }, 'publicProfiles/share': projection(job()) });
  for (const db of [visitor(), env.authenticatedContext('other', { email: 'other@example.com', email_verified: true }).firestore()]) {
    await assertFails(getDoc(doc(db, 'jobs/job')));
    await assertFails(getDocs(collection(db, 'jobs')));
    await assertFails(getDoc(doc(db, 'profileSlugs/share')));
    await assertFails(getDocs(collection(db, 'publicProfiles')));
    const result = await assertSucceeds(getDoc(doc(db, 'publicProfiles/share')));
    assert.equal(result.data().description, undefined);
    assert.equal(result.data().company, undefined);
    assert.equal(result.data().title, undefined);
  }
});

test('inactive and expired links are unreadable even by known slug', async () => {
  await seed({
    'publicProfiles/active': projection(job('active', { expiresAt: future })),
    'publicProfiles/inactive': projection(job('inactive', { isActive: false })),
    'publicProfiles/expired': projection(job('expired', { expiresAt: past })),
  });
  await assertSucceeds(getDoc(doc(visitor(), 'publicProfiles/active')));
  await assertFails(getDoc(doc(visitor(), 'publicProfiles/inactive')));
  await assertFails(getDoc(doc(visitor(), 'publicProfiles/expired')));
});

test('public content queries must explicitly restrict to active records', async () => {
  await seed({ 'projects/project': project(), 'projects/hidden': project({ isActive: false }) });
  const db = visitor();
  await assertSucceeds(getDoc(doc(db, 'projects/project')));
  await assertFails(getDoc(doc(db, 'projects/hidden')));
  await assertFails(getDocs(collection(db, 'projects')));
  await assertSucceeds(getDocs(query(collection(db, 'projects'), where('isActive', '==', true), orderBy('order'))))
    .catch((error) => { throw new Error('Active projects ordered query failed', { cause: error }); });
  // A mixed-active IN query is denied as a whole. The Dart service reads known
  // IDs in bounded groups and omits each denied/archived record instead.
  await assertFails(getDocs(query(collection(db, 'projects'), where('isActive', '==', true), where(documentId(), 'in', ['project', 'hidden']))));
  const selected = await Promise.all(['hidden', 'project', 'missing'].map(async (id) => {
    try { const entry = await getDoc(doc(db, `projects/${id}`)); return entry.data()?.isActive === true ? entry.id : null; }
    catch (error) { if (error.code === 'permission-denied') return null; throw error; }
  }));
  assert.deepEqual(selected.filter(Boolean), ['project']);
});

test('only verified owner or trusted admin claim can write', async () => {
  const data = project({ createdAt: serverTimestamp(), updatedAt: serverTimestamp() });
  const unverified = env.authenticatedContext('owner-unverified', { email: 'thejaynesh@gmail.com', email_verified: false }).firestore();
  await assertFails(setDoc(doc(unverified, 'projects/project'), data));
  await assertFails(setDoc(doc(visitor(), 'projects/project'), data));
  await assertSucceeds(setDoc(doc(admin(), 'projects/project'), data));
  await assertSucceeds(setDoc(doc(env.authenticatedContext('claims-admin', { admin: true }).firestore(), 'projects/claim'), data));
  await assertFails(setDoc(doc(visitor(), 'users/attacker'), { admin: true }));
});

test('create and update both validate types, sizes, keys and timestamps', async () => {
  const db = admin();
  const valid = project({ createdAt: serverTimestamp(), updatedAt: serverTimestamp() });
  await assertSucceeds(setDoc(doc(db, 'projects/project'), valid));
  for (const bad of [
    { title: 7 }, { title: 'x'.repeat(201) }, { unknown: true }, { techStack: [1] },
    { techStack: ['x'.repeat(201)] }, { link: 'javascript:alert(1)' }, { order: -1 },
    { link: 'https://user:password@example.com' }, { link: 'https://exa mple.com' },
    { techStack: Array(51).fill('Dart') }, { createdAt: past },
  ]) {
    await assertFails(setDoc(doc(db, 'projects/new'), { ...valid, ...bad }));
    await assertFails(updateDoc(doc(db, 'projects/project'), { ...bad, updatedAt: serverTimestamp() }));
  }
  await assertFails(deleteDoc(doc(db, 'projects/project')));
  await assertSucceeds(updateDoc(doc(db, 'projects/project'), { isActive: false, updatedAt: serverTimestamp() }));
  await assertFails(getDoc(doc(visitor(), 'projects/project')));
});

test('actual seed settings pass authorization/structural validation and invalid shapes fail', async () => {
  const data = JSON.parse(await readFile(new URL('../../scripts/seed_data.json', import.meta.url), 'utf8'));
  // The maintenance preflight normalizes the historical bare social URLs.
  for (const key of ['github', 'linkedin', 'twitter', 'instagram', 'resumeUrl']) {
    const value = data.settings[key];
    if (value && !value.startsWith('/') && !value.includes('://')) data.settings[key] = `https://${value}`;
  }
  const db = admin();
  await assertSucceeds(setDoc(doc(db, 'settings/main'), data.settings));
  await assertSucceeds(getDoc(doc(visitor(), 'settings/main')));
  await assertFails(getDocs(collection(visitor(), 'settings')));
  for (const changes of [
    { email: 'not-an-email' }, { quiz: 'not a list' },
    { highlights: 'not a list' }, { awards: [{}] },
    { defaultProjectIds: ['a', 'a'] }, { defaultExperienceIds: ['../bad'] },
    { certifications: Array(13).fill({ name: 'Certificate' }) },
  ]) {
    await assertFails(updateDoc(doc(db, 'settings/main'), changes));
  }
  await assertFails(setDoc(doc(db, 'settings/private'), { name: 'Secret' }));
  // Detailed nested text/quiz validation is covered by the Dart and Python
  // suites. Authorized full-document saves must stay inside Rules' budget.
  const maximum = { ...data.settings };
  for (const field of ['highlights', 'skillGroups', 'education', 'quiz', 'personality', 'certifications']) {
    maximum[field] = Array.from({ length: 12 }, () => data.settings[field][0]);
  }
  maximum.defaultProjectIds = Array.from({ length: 100 }, (_, i) => `project-${i}`);
  maximum.defaultExperienceIds = Array.from({ length: 100 }, (_, i) => `experience-${i}`);
  await assertSucceeds(setDoc(doc(db, 'settings/main'), maximum));
});

test('projects and experience from the seed meet publication constraints', async () => {
  const data = JSON.parse(await readFile(new URL('../../scripts/seed_data.json', import.meta.url), 'utf8'));
  const db = admin();
  for (const [i, value] of data.projects.entries()) {
    await assertSucceeds(setDoc(doc(db, `projects/seed-${i}`), { ...value, order: i, createdAt: serverTimestamp(), updatedAt: serverTimestamp() }));
  }
  for (const [i, value] of data.experience.entries()) {
    await assertSucceeds(setDoc(doc(db, `experience/seed-${i}`), { ...value, order: i, createdAt: serverTimestamp(), updatedAt: serverTimestamp() }));
  }
});

test('job creation requires atomic matching reservation and projection', async () => {
  const db = admin();
  const data = job('share', { createdAt: serverTimestamp(), updatedAt: serverTimestamp() });
  await assertFails(setDoc(doc(db, 'jobs/job'), data));
  await assertSucceeds(publish(db, 'job', data));
  await assertSucceeds(getDoc(doc(visitor(), 'publicProfiles/share')));
  await assertFails(setDoc(doc(db, 'publicProfiles/share'), { ...projection(data), description: 'Leak' }));
  await assertFails(updateDoc(doc(db, 'publicProfiles/share'), { customAbout: 'Different copy' }));
  await assertFails(updateDoc(doc(visitor(), 'jobs/job'), { viewCount: 1 }));
  await assertFails(updateDoc(doc(db, 'jobs/job'), { viewCount: 1, updatedAt: serverTimestamp() }));
});

test('atomic editing, clearing expiry, renaming and deletion keep link state consistent', async () => {
  const db = admin();
  const original = job('old', { expiresAt: future, viewCount: 7 });
  await seed({ 'jobs/job': original, 'profileSlugs/old': { jobId: 'job' }, 'publicProfiles/old': projection(original) });
  const updated = { ...original, slug: 'new', customAbout: null, expiresAt: null, updatedAt: serverTimestamp() };
  const batch = writeBatch(db);
  batch.set(doc(db, 'jobs/job'), updated);
  batch.set(doc(db, 'profileSlugs/new'), { jobId: 'job' });
  batch.set(doc(db, 'publicProfiles/new'), projection(updated));
  batch.delete(doc(db, 'profileSlugs/old'));
  batch.delete(doc(db, 'publicProfiles/old'));
  await assertSucceeds(batch.commit());
  const publicData = (await assertSucceeds(getDoc(doc(visitor(), 'publicProfiles/new')))).data();
  assert.equal(publicData.expiresAt, null);
  assert.equal(publicData.customAbout, null);
  assert.equal((await getDoc(doc(db, 'jobs/job'))).data().viewCount, 7);
  await assertFails(deleteDoc(doc(db, 'jobs/job')));
  const removal = writeBatch(db);
  removal.delete(doc(db, 'jobs/job'));
  removal.delete(doc(db, 'profileSlugs/new'));
  removal.delete(doc(db, 'publicProfiles/new'));
  await assertSucceeds(removal.commit());
  assert.equal((await getDoc(doc(db, 'jobs/job'))).exists(), false);
});

test('competing transactions cannot reserve the same slug for different jobs', async () => {
  const db = admin();
  const reserve = (id) => runTransaction(db, async (tx) => {
    const ref = doc(db, 'profileSlugs/same');
    if ((await tx.get(ref)).exists()) throw new Error('Slug is already reserved');
    const data = job('same', { createdAt: serverTimestamp(), updatedAt: serverTimestamp() });
    tx.set(doc(db, `jobs/${id}`), data);
    tx.set(ref, { jobId: id });
    tx.set(doc(db, 'publicProfiles/same'), projection(data));
  });
  const results = await Promise.allSettled([reserve('first'), reserve('second')]);
  assert.equal(results.filter((result) => result.status === 'fulfilled').length, 1);
  assert.equal((await getDocs(collection(db, 'jobs'))).size, 1);
});
