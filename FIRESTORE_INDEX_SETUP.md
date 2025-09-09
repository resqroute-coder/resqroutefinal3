# Firestore Index Setup Instructions

## Required Composite Index

Your app needs a composite index for the `emergency_requests` collection to support queries that filter by both `patientId` and `status`.

### Index Configuration

**Collection:** `emergency_requests`

**Fields to index:**
1. `patientId` (Ascending)
2. `status` (Ascending) 
3. `createdAt` (Descending) - for ordering

### How to Create the Index

#### Method 1: Using Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your ResQRoute project
3. Navigate to **Firestore Database** → **Indexes** tab
4. Click **Create Index**
5. Configure the index:
   - **Collection ID:** `emergency_requests`
   - **Fields:**
     - Field: `patientId`, Order: `Ascending`
     - Field: `status`, Order: `Ascending`
     - Field: `createdAt`, Order: `Descending`
6. Click **Create**

#### Method 2: Using the Error Link

When you run the app and trigger the query, Firestore will show an error with a direct link to create the index. Click that link and it will pre-configure the index for you.

#### Method 3: Using Firebase CLI (if installed)

```bash
firebase firestore:indexes
```

Then add this to your `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "emergency_requests",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "patientId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status", 
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

Then deploy:
```bash
firebase deploy --only firestore:indexes
```

### Why This Index is Needed

The app uses these queries that require the composite index:

1. **Active Requests Query** (`getPatientActiveRequestStream`):
   ```dart
   .where('patientId', isEqualTo: patientId)
   .where('status', whereIn: ['pending', 'accepted', 'picked_up', 'en_route'])
   ```

2. **History Requests Query** (`getPatientHistoryStream`):
   ```dart
   .where('patientId', isEqualTo: patientId) 
   .where('status', whereIn: ['completed', 'cancelled'])
   ```

Both queries filter by multiple fields and need a composite index to work efficiently.

### Index Creation Time

- Index creation typically takes a few minutes for small datasets
- For larger datasets, it may take longer
- You'll receive an email notification when the index is ready

### Verification

After creating the index:
1. Wait for the index to be built (status shows "Enabled")
2. Test the emergency request flow in your app
3. The queries should work without errors

## Notes

- This index will improve query performance
- Firestore automatically creates single-field indexes
- Composite indexes must be created manually for multi-field queries
- The index supports both equality and array-contains-any operations used in the queries
