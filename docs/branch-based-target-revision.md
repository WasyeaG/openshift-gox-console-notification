
---

## Rollback Strategy

Rollback is performed through Git rather than by modifying resources manually in the cluster.

Recommended rollback process:

1. Identify the last known-good commit for the affected environment branch.
2. Revert the faulty commit or merged pull request.
3. Merge or push the revert commit to the affected environment branch.
4. Allow the deployment workflow and Argo CD to reconcile the previous state.
5. Verify that the Argo CD Application returns to `Synced` and `Healthy`.

For an urgent recovery, the environment branch can be reset to a previously validated commit, but a revert commit is preferred because it preserves the complete audit history.

---

## Auditability

The branch-based model provides deployment traceability through:

- Git commit history
- Pull request and approval history
- GitHub Actions workflow runs
- Rendered ApplicationSet artifacts
- Argo CD synchronization history
- The commit associated with each environment branch

Because branches are mutable, the deployed commit SHA should be recorded in workflow output or deployment evidence.

---

## Risks and Operational Trade-offs

### Branch Drift

Long-lived environment branches can diverge, causing environments to contain different changes beyond their intended promotion level.

**Mitigation:**

- Promote changes in order: `sbx` to `stg` to `main`.
- Use pull requests for every promotion.
- Regularly compare environment branches.
- Prevent direct commits to protected environment branches.

### Merge Conflicts

Delayed promotions can result in merge conflicts between environment branches.

**Mitigation:**

- Promote small changes frequently.
- Keep the branch history linear where practical.
- Resolve conflicts through reviewed pull requests.

### Mutable References

A branch can move to a different commit while retaining the same branch name.

**Impact:**

A branch name alone is insufficient to identify the exact deployed version.

**Mitigation:**

- Record the resolved commit SHA in deployment logs.
- Use immutable tags or commit SHAs for production releases when stronger release controls are required.

### Workflow Dependency on `main`

The caller workflow references the reusable workflow using `@main`.

**Risk:**

A change to the reusable workflow can affect all environments without updating the caller repository.

**Mitigation:**

- Pin the reusable workflow to a release tag or commit SHA.
- Test reusable workflow changes before updating the pinned reference.

### Human Error

Direct commits or incorrect merges can bypass the intended promotion process.

**Mitigation:**

- Enable branch protection.
- Require pull request reviews.
- Require successful status checks.
- Restrict force pushes and branch deletion.

### Credential Exposure and Scope

The deployment workflow uses environment-specific OpenShift tokens.

**Mitigation:**

- Use a dedicated service account per environment.
- Grant only the minimum required RBAC permissions.
- Rotate tokens regularly.
- Store credentials only as GitHub Actions secrets.

---

## Prototype Limitations

The current prototype has the following limitations:

- Only the `gox-sbx` deployment has been validated end to end.
- Staging and production-like branches render correctly but have not been applied and validated.
- Promotion between branches remains manual.
- Rollback remains a documented manual Git operation.
- Reusable workflows are referenced using the mutable `main` branch.
- Workflow output does not yet prominently report the resolved application commit SHA.
- Push-triggered runs default to render-only behavior; deployment requires an explicit workflow dispatch with `dry_run=false`.
- OpenShift authentication currently skips TLS certificate validation.
- No formal approval gate is configured for the production-like environment.

---

## Proposed Improvements

Recommended future improvements include:

- Validate the complete deployment flow for `gox-stg` and `gox-prd`.
- Configure GitHub branch protection for `sbx`, `stg`, and `main`.
- Use GitHub Environments with required approval for production-like deployment.
- Pin reusable workflows to immutable release tags or commit SHAs.
- Report the resolved application commit SHA in workflow summaries.
- Add automated branch comparison and promotion checks.
- Add automated rollback workflow support.
- Replace long-lived tokens with a stronger short-lived authentication method where supported.
- Configure trusted OpenShift certificate authorities instead of using `--insecure-skip-tls-verify`.
- Evaluate a tag-based model for immutable production releases.

---

## Conclusion

The prototype proves that the Console Notification workload can be deployed through Argo CD using an environment-specific Git branch as `targetRevision`.

The sandbox deployment successfully tracks the `sbx` branch and is currently `Synced` and `Healthy`. The model is suitable for experimentation and lower-environment validation, while additional controls would be required before adopting it as a production delivery standard.
