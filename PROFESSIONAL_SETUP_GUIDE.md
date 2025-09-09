# Professional Account Setup Guide

This guide shows you how to create professional accounts (Driver, Police, Hospital) that can log in with Employee ID + Password.

## What's Been Updated

✅ **Firestore Rules**: Updated to support professional login while keeping patient flow intact
✅ **Professional Login Screen**: Cleaned up (removed demo credentials)
✅ **Authentication Flow**: Uses Firebase Auth with internal emails behind Employee ID + Password UI

## Step-by-Step Setup

### Step 1: Create Firebase Auth User

1. Go to **Firebase Console** → **Authentication** → **Users**
2. Click **"Add user"**
3. **Email**: Use internal format like `emp001@pro.resqroute` (users never see this)
4. **Password**: Set the password the professional will type in the app
5. Click **"Add user"**
6. **Copy the generated User UID** (you'll need it in Step 2)

### Step 2: Create Firestore User Profile

1. Go to **Firebase Console** → **Firestore Database** → **Data**
2. Collection: **`users`**
3. Document ID: **Paste the UID from Step 1**
4. Add these fields:

```json
{
  "role": "driver",                    // or "hospital_staff" or "traffic_police"
  "employeeId": "EMP001",             // What they type in the app
  "email": "emp001@pro.resqroute",    // Must match Step 1 email
  "fullName": "John Driver",          // Optional but recommended
  "phone": "+91 91234 56789",         // Optional
  "createdAt": "Server timestamp",    // Optional
  "updatedAt": "Server timestamp"     // Optional
}
```

### Step 3: Department to Role Mapping

| Department (UI) | Role (Firestore) | Dashboard Route |
|----------------|------------------|-----------------|
| Ambulance Driver | `driver` | `/driver-dashboard` |
| Traffic Police | `traffic_police` | `/traffic-police-dashboard` |
| Hospital Admin | `hospital_staff` | `/hospital-dashboard` |

## Example Professional Accounts

### Driver Example
**Firebase Auth:**
- Email: `driver001@pro.resqroute`
- Password: `SecurePass123`

**Firestore users/{uid}:**
```json
{
  "role": "driver",
  "employeeId": "DRV001",
  "email": "driver001@pro.resqroute",
  "fullName": "Raj Sharma",
  "phone": "+91 98765 43210"
}
```

**Login in App:**
- Department: Ambulance Driver
- Employee ID: DRV001
- Password: SecurePass123

### Police Example
**Firebase Auth:**
- Email: `police001@pro.resqroute`
- Password: `TrafficPass456`

**Firestore users/{uid}:**
```json
{
  "role": "traffic_police",
  "employeeId": "POL001",
  "email": "police001@pro.resqroute",
  "fullName": "Priya Patel",
  "phone": "+91 87654 32109"
}
```

**Login in App:**
- Department: Traffic Police
- Employee ID: POL001
- Password: TrafficPass456

### Hospital Example
**Firebase Auth:**
- Email: `hospital001@pro.resqroute`
- Password: `HospitalPass789`

**Firestore users/{uid}:**
```json
{
  "role": "hospital_staff",
  "employeeId": "HSP001",
  "email": "hospital001@pro.resqroute",
  "fullName": "Dr. Amit Kumar",
  "phone": "+91 76543 21098"
}
```

**Login in App:**
- Department: Hospital Admin
- Employee ID: HSP001
- Password: HospitalPass789

## Testing Checklist

### Patient Flow (Should Work Unchanged)
- [ ] Patient registration creates `users/{uid}` with `role: 'patient'`
- [ ] Patient can log in with email + password
- [ ] Patient dashboard shows data from UserService
- [ ] Patient can create emergency requests
- [ ] Emergency requests appear in `emergency_requests` collection

### Professional Flow (New)
- [ ] Professional can log in with Department + Employee ID + Password
- [ ] Professional gets routed to correct dashboard
- [ ] Professional can read emergency requests (but not create them)
- [ ] No errors in console during professional login

## Important Notes

1. **Patient data is safe**: All existing patient data in `users` collection remains unchanged
2. **Emergency requests unchanged**: Creation and structure remain exactly the same
3. **No Gmail required**: Professionals never see or type email addresses
4. **Secure**: Uses Firebase Auth for password verification, not stored in Firestore
5. **Role-based**: Each professional has a role that can be used for future features

## Troubleshooting

**"No account found for this Employee ID"**
- Check that `employeeId` in Firestore matches exactly what was typed
- Check that `role` matches the selected department

**"Invalid credentials"**
- Check that the password in Firebase Auth matches what was typed
- Check that `email` in Firestore matches the Auth email exactly

**"Access Denied"**
- Check that the signed-in user's `users/{uid}` doc has the correct `role` and `employeeId`

## Next Steps (Later)

Once you're ready to add professional features:
- Extend Firestore rules to allow professionals to update emergency requests
- Add driver "accept request" functionality
- Add hospital bed management
- Add traffic police route clearance
