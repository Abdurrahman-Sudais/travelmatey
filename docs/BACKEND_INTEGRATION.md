# Backend Integration Guide

This document is for the backend engineer picking up TravelMate after the UI shell.

## Quick start

1. Set the API base URL when running or building:
   ```bash
   flutter run --dart-define=API_BASE_URL=https://staging-api.yourdomain.com/v1
   ```
2. Open `lib/core/config/app_config.dart` and set `useMockRepositories = false`.
3. Implement the endpoints listed in `lib/core/api/api_endpoints.dart`.
4. Match JSON field names used in `lib/data/models/` (snake_case in API, mapped in `fromJson`).

## Architecture

```
UI (pages/widgets)
    ↓
Repository (lib/data/repositories/)   ← inject via Get.find / ServiceLocator
    ↓
ApiClient (lib/core/api/api_client.dart)
    ↓
Your REST API
```

**Do not call `ApiClient` from widgets.** Add or extend a repository, register it in `lib/core/di/service_locator.dart`, then consume it from the UI.

## Authentication

After sign-in, the backend should return:

```json
{
  "data": {
    "access_token": "...",
    "refresh_token": "...",
    "user": { ... }
  }
}
```

Wire token storage (e.g. `flutter_secure_storage`) and call:

```dart
Get.find<ApiClient>().setAuthToken(accessToken);
```

Implement refresh on HTTP 401 inside `ApiClient._handleResponse`.

## Response envelope

The app expects a consistent shape:

```json
{
  "data": { ... },
  "message": "optional"
}
```

Errors:

```json
{
  "message": "Human readable error",
  "code": "VALIDATION_ERROR"
}
```

Thrown as `ApiException` in `api_client.dart`.

## File uploads

| Feature | Endpoint | Multipart field | Extra fields |
|---------|----------|-----------------|--------------|
| Profile avatar | `POST /users/me/avatar` | `file` | — |
| KYC document | `POST /kyc/documents` | `file` | `type` = `identity` \| `address` \| `face` |

Response should include document id (and optional CDN `url`):

```json
{
  "data": {
    "id": "doc_abc123",
    "url": "https://cdn.example.com/..."
  }
}
```

Frontend flow is already wired in:

- `UserRepository.uploadAvatar` — profile photo
- `KycRepository.uploadDocument` — KYC steps
- `KycRepository.submitKyc` — final submit with document ids

## Wallet

Mock wallet lives in `MockWalletRepository`. Replace with real calls:

| Action | Endpoint | Body |
|--------|----------|------|
| Balance | `GET /wallet` | — |
| Fund | `POST /wallet/fund` | `amount`, `method` |
| Airtime | `POST /wallet/airtime` | `network`, `phone`, `amount` |
| Data | `POST /wallet/data` | `network`, `phone`, `plan_id`, `amount` |
| Bills | `POST /wallet/bills` | `category`, `provider`, `account_number`, `amount` |

## KYC submit payload

See `KycSubmission.toJson()` in `lib/data/models/kyc_model.dart`.

## Still UI-only (backend needed)

- Rides / bookings lists (hardcoded in page widgets)
- Messages / chat
- Live trip tracking / maps
- Push notifications
- Payment gateway tokenization (card funding UI collects fields locally only)

Recommended next repos to add: `AuthRepository`, `RideRepository`, `BookingRepository`, `MessagesRepository`.

## Testing against mocks

While `useMockRepositories = true` (default), all repository calls simulate latency and update in-memory state. Safe for UI demos without a server.
