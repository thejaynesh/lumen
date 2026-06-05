"""
Firestore seed script for Lumen portfolio app (project: lumen-f2e07).

Usage:
    python seed_firestore.py           # seed without wiping existing data
    python seed_firestore.py --wipe    # delete all projects + experience docs first, then seed

WARNING: This script MUTATES production Firestore. Review seed_data.json before running.
A human must run this manually — it is NOT invoked by CI or any automated process.
"""

import argparse
import json
import os
import sys

import firebase_admin
from firebase_admin import credentials, firestore


def batch_delete_collection(db, collection_name):
    """Delete all documents in a collection using batched deletes."""
    col_ref = db.collection(collection_name)
    docs = col_ref.stream()
    batch = db.batch()
    count = 0
    for doc in docs:
        batch.delete(doc.reference)
        count += 1
        if count % 500 == 0:
            batch.commit()
            batch = db.batch()
    if count % 500 != 0:
        batch.commit()
    print(f"  Deleted {count} docs from '{collection_name}'")


def main():
    parser = argparse.ArgumentParser(
        description="Seed Firestore with Lumen portfolio content from seed_data.json."
    )
    parser.add_argument(
        "--wipe",
        action="store_true",
        help="Delete all docs in 'projects' and 'experience' collections before seeding.",
    )
    args = parser.parse_args()

    # Resolve paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sa_path = os.path.normpath(os.path.join(script_dir, "..", "..", "secrets", "lumen-sa.json"))
    data_path = os.path.join(script_dir, "seed_data.json")

    # Validate service account
    if not os.path.isfile(sa_path):
        print(f"ERROR: Service account JSON not found at:\n  {sa_path}", file=sys.stderr)
        sys.exit(1)

    # Validate data file
    if not os.path.isfile(data_path):
        print(f"ERROR: seed_data.json not found at:\n  {data_path}", file=sys.stderr)
        sys.exit(1)

    # Load seed data
    with open(data_path, encoding="utf-8") as f:
        seed = json.load(f)

    settings_dict = seed["settings"]
    projects_list = seed["projects"]
    experience_list = seed["experience"]

    # Initialize Firebase
    cred = credentials.Certificate(sa_path)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    # Optional wipe
    if args.wipe:
        print("--wipe flag set. Deleting existing collections...")
        batch_delete_collection(db, "projects")
        batch_delete_collection(db, "experience")

    # Write settings/main (without defaultProjectIds/defaultExperienceIds for now)
    settings_to_write = {k: v for k, v in settings_dict.items()
                         if k not in ("defaultProjectIds", "defaultExperienceIds")}
    settings_to_write["defaultProjectIds"] = []
    settings_to_write["defaultExperienceIds"] = []
    db.collection("settings").document("main").set(settings_to_write)
    print("settings/main written")

    # Seed projects
    project_ids = []
    for i, project in enumerate(projects_list):
        doc = dict(project)
        doc["order"] = i
        doc["createdAt"] = firestore.SERVER_TIMESTAMP
        doc["updatedAt"] = firestore.SERVER_TIMESTAMP
        _, ref = db.collection("projects").add(doc)
        project_ids.append(ref.id)
    print(f"projects written: {len(project_ids)}")

    # Seed experience
    experience_ids = []
    for i, exp in enumerate(experience_list):
        doc = dict(exp)
        doc["order"] = i
        doc["createdAt"] = firestore.SERVER_TIMESTAMP
        doc["updatedAt"] = firestore.SERVER_TIMESTAMP
        _, ref = db.collection("experience").add(doc)
        experience_ids.append(ref.id)
    print(f"experience written: {len(experience_ids)}")

    # Update settings/main with default IDs
    db.collection("settings").document("main").update({
        "defaultProjectIds": project_ids,
        "defaultExperienceIds": experience_ids,
    })
    print("defaults updated")
    print(f"\nDone. Project IDs: {project_ids}")
    print(f"Experience IDs: {experience_ids}")


if __name__ == "__main__":
    main()
