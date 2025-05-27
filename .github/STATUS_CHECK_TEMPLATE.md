---
title: ⚠️ Status Check Failure {{ date | date('YYYY-MM-DD HH:mm') }}
labels: incident, priority-high
assignees: devops-team
---

# Status Check Failure

**Time:** {{ date | date('YYYY-MM-DD HH:mm:ss') }} UTC
**Environment:** Production

## Service Status

| Service      | Status                                            |
| ------------ | ------------------------------------------------- | --- | ------------ |
| API          | {{ env.API_HEALTHY == 'true' && '✅ Healthy'      |     | '❌ Down' }} |
| Frontend     | {{ env.FRONTEND_HEALTHY == 'true' && '✅ Healthy' |     | '❌ Down' }} |
| Bridge       | {{ env.BRIDGE_HEALTHY == 'true' && '✅ Healthy'   |     | '❌ Down' }} |
| PQC Services | {{ env.PQC_HEALTHY == 'true' && '✅ Healthy'      |     | '❌ Down' }} |

## Next Steps

1. Check the [status dashboard](https://status.zkvote.io)
2. Review logs in [Datadog](https://app.datadoghq.com/dashboard/zkVote)
3. Update the incident in the [incident log](https://github.com/zkvote/ops-handbook/incidents)
4. Verify blockchain attestations via [attestation explorer](https://attestations.zkvote.io)

Please update this issue with your findings.
