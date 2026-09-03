# Admin Cloud Firestore Recipe Seeder

This directory contains a one-time administrative script to seed sample recipes into Cloud Firestore for project `recipe-app-39d4f`.

> **Security Note**: This script runs outside the Flutter client application. Client-side security rules remain strictly read-only (`allow write: if false;`). Credential files like `service-account.json` are protected by `.gitignore` and must **never** be committed.

---

## Instructions to Run Seeder

### Option 1: Service Account Key (Recommended)

1. Go to **[Firebase Console](https://console.firebase.google.com/)** -> Select project **recipe-app-39d4f**.
2. Navigate to **Project Settings** (gear icon) -> **Service accounts**.
3. Click **Generate new private key** and download the JSON key file.
4. Rename/save the key file as:
   ```text
   scripts/service-account.json
   ```
5. Execute the seeder script:
   ```bash
   node scripts/seed_firestore.js
   ```

---

### Option 2: Application Default Credentials (ADC)

If you have configured Google Cloud Application Default Credentials on your local machine:
```bash
node scripts/seed_firestore.js
```

---

## Features of `seed_firestore.js`

- **Idempotent / Overwrite Protection**: Checks if `recipes` collection already contains documents. If documents exist, seeding stops automatically to prevent overwriting or duplicating data.
- **Data Validation**: Reads `assets/sample_recipes_dataset.json` and converts dates to native Firestore `Timestamp` objects.
- **Batch Insertion**: Inserts recipes efficiently via Firestore batch writes.
