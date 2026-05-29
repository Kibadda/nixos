# Plan: Redo Restic Backup Module for S3 Glacier

## Summary

Update `restic.nix` to use S3 Glacier for cost savings with 5-backup retention. Keep restic's built-in AES-256 encryption.

## Key Insight: S3 Glacier Compatibility

Restic requires random access to repository data, which is incompatible with Glacier's retrieval delays. The solution is to use **S3 Lifecycle Policies** that automatically transition data:

- Days 0-29: S3 Standard (immediate access)
- Days 30-89: S3 Standard-IA (~45% cheaper)
- Days 90+: S3 Glacier Instant Retrieval (~83% cheaper, millisecond access)

This gives you Glacier pricing while maintaining restic functionality.

## Changes Required

### 1. Update `restic.nix` - Change Retention Policy

**File:** `/home/michael/Projects/Personal/nixos/modules/services/restic.nix`

Change `pruneOpts` from:
```nix
pruneOpts = [
  "--keep-daily 7"
  "--keep-weekly 3"
  "--keep-monthly 3"
];
```

To:
```nix
pruneOpts = [
  "--keep-last 5"
];
```

### 2. Configure AWS S3 Lifecycle Policy (Manual Step)

Apply this lifecycle policy to your S3 bucket:

```bash
aws s3api put-bucket-lifecycle-configuration \
  --bucket kibadda-backup-oberon \
  --lifecycle-configuration '{
    "Rules": [
      {
        "ID": "TransitionToGlacier",
        "Status": "Enabled",
        "Filter": {},
        "Transitions": [
          { "Days": 30, "StorageClass": "STANDARD_IA" },
          { "Days": 90, "StorageClass": "GLACIER_IR" }
        ]
      }
    ]
  }'
```

## No Changes Needed

- **Encryption**: Keeping restic's built-in AES-256 encryption (already secure)
- **Daily backups**: Already configured via per-service `backup.time`
- **Secrets**: No changes to `/home/michael/Projects/Personal/nixos/secrets/pi.nix`

## Cost Estimate (100GB of backup data)

| Period | Storage Class | Monthly Cost |
|--------|--------------|--------------|
| Current | S3 Standard | ~$2.30 |
| After 30d | Standard-IA | ~$1.25 |
| After 90d | Glacier IR | ~$0.40 |

## Verification

1. Rebuild NixOS and deploy to oberon
2. Wait for backup to run (or trigger manually)
3. Verify retention: `restic -r <repo> snapshots` should show max 5 snapshots
4. After 30+ days, verify lifecycle: `aws s3api head-object --bucket kibadda-backup-oberon --key <object>` to check StorageClass

## Files to Modify

- `/home/michael/Projects/Personal/nixos/modules/services/restic.nix` (retention change)
