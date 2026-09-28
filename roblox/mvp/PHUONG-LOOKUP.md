# Phuong account lookup evidence

On 2026-09-27, Roblox's official public endpoint `https://users.roblox.com/v1/usernames/users` returned:

```json
{"requestedUsername":"Phamlet707","hasVerifiedBadge":false,"id":3971290001,"name":"Phamlet707","displayName":"Phamlet707"}
```

The MVP config uses this exact numeric ID for Phuong. A second official lookup on the same endpoint returned `IamBannedrew` with numeric ID `1078077474`; this is the explicit birthday host fallback. Phuong remains a direct host-equivalent actor. The fallback is used for spending/cake controls only while Phuong is absent; no arbitrary guest receives authority. Any Studio-only test override must be injected separately and must never replace this published configuration.

```json
{"requestedUsername":"IamBannedrew","hasVerifiedBadge":false,"id":1078077474,"name":"IamBannedrew","displayName":"IamBannedrew"}
```
