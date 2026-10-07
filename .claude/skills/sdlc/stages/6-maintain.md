# Stage 6 — Maintain

Once the change is merged and deployed.

- **A bug fix's regression test belongs in `evals/` too.** Each incident
  class becomes a permanent eval, so the same failure can't recur — see
  `evals/README.md`.
- **Breaches write the next intent.** A monitoring script watches SLOs
  against `bands.yaml`. A breach past the top band writes a new
  `intent/<slug>.md` carrying the anomaly evidence, as `status: draft`, and
  the loop starts again at Stage 1: a service owner triages it, and a product
  owner approves it like any other intent.

The skeleton ships `bands.yaml`'s shape but no monitoring script — that part
is specific to your metrics stack.
