# StackQL GitHub Actions Demo

This repository demonstrates using [__StackQL__](https://github.com/stackql/stackql) with GitHub Actions.  StackQL can provision, de-provision, and perform lifecycle operations on cloud resources across all major cloud providers.  

StackQL GitHub Actions include:
- [__`setup-stackql`__](https://github.com/marketplace/actions/stackql-studios-setup-stackql) : Installs the `stackql` cli on actions runners, used if you want to perform custom operations using StackQL
- [__`stackql-exec`__](https://github.com/marketplace/actions/stackql-studios-stackql-exec) : Executes a StackQL query within an Actions workflow; this could be used to provision, de-provision, or perform lifecycle operations on cloud resources (using the [`INSERT`](https://stackql.io/docs/language-spec/insert), `UPDATE`, [`DELETE`](https://stackql.io/docs/language-spec/delete), [`EXEC`](https://stackql.io/docs/language-spec/exec) methods), as well as running queries and returning results to the log, file or variable (using the [`SELECT`](https://stackql.io/docs/language-spec/select) method)
- [__`stackql-assert`__](https://github.com/marketplace/actions/stackql-studios-stackql-assert) : Used to test assertions against the results of a StackQL query, this can be used to validate the state of a resource after an IaC or lifecycle operation has been performed, or to validate the system (e.g., CSPM or compliance queries) 

## Prerequisites

Authentication to StackQL providers is done via environment variables source from GitHub Actions Secrets. To learn more about authentication, see the setup instructions for your provider or providers at the [StackQL Provider Registry Docs](https://registry.stackql.io/). 

## Demo workflow

The demo workflow in this repository is configured to run on a push to the `main` branch and performs the following steps:  

```mermaid
flowchart TB
    1[setup StackQL\n<code><b>setup-stackql</b></code>]-->2[dry run query\nusing <code><b>stackql</b></code>];
    2-->3[deploy instances\nusing <code><b>stackql-exec</b></code>];
    3-->4[stop instances\nusing <code><b>stackql-exec</b></code>];
    4-->5[validate deployment\nusing <code><b>stackql-assert</b></code>];
    5-->6;

    subgraph "Terraform Validation"
        6[deploy instances\nusing <code><b>terraform</b></code>]-->7[validate deployment\nusing <code><b>stackql-assert</b></code>];
    end
```

Workflow fragments are explained here:  

### setup StackQL

This step uses the [__`setup-stackql`__](https://github.com/marketplace/actions/stackql-studios-setup-stackql) action to install the `stackql` cli on the actions runner, which is then available to all subsequent steps in the job via `stackql`.  

```yaml
- name: setup StackQL
  uses: stackql/setup-stackql@v1.2.0
  with:
    use_wrapper: true
```

### dry run StackQL query

This step demonstrates how to use the `stackql` cli (after the previous `setup-stackql` action is used) to perform a dry run of a StackQL query - which will return a rendered template of your query with all of the fields populated; this is useful for debugging and validating your queries.  

```yaml
- name: dry run StackQL query
  shell: bash
  run: |
    stackql exec \
    -i ./stackql/scripts/deploy-instances/deploy-instances.iql \
    --iqldata ./stackql/data/vars.jsonnet \
    --var GOOGLE_PROJECT=${{ env.GOOGLE_PROJECT }},GOOGLE_ZONE=${{ env.GOOGLE_ZONE }} \
    --output text -H --dryrun
  env:
    GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }}
    GOOGLE_PROJECT: ${{ vars.GOOGLE_PROJECT }}
    GOOGLE_ZONE: ${{ vars.GOOGLE_ZONE }}    
```
### deploy instances using `stackql-exec`

This step demonstrates how to use the [__`stackql-exec`__](https://github.com/marketplace/actions/stackql-studios-stackql-exec) method to perform a StackQL query; in this case, we are using the `INSERT` method to deploy instances on GCP.  

```yaml
- name: deploy instances using stackql-exec
  uses: stackql/stackql-exec@v1.3.1
  with:
    query_file_path: './stackql/scripts/deploy-instances/deploy-instances.iql'
    data_file_path: './stackql/data/vars.jsonnet'
    vars: GOOGLE_PROJECT=${{ env.GOOGLE_PROJECT }},GOOGLE_ZONE=${{ env.GOOGLE_ZONE }}
  env:
    GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }}
    GOOGLE_PROJECT: ${{ vars.GOOGLE_PROJECT }}
    GOOGLE_ZONE: ${{ vars.GOOGLE_ZONE }}
```

### stop running instances using `stackql-exec`

This step demonstrates how to use `stackql` via the `stackql-exec` action to perform lifecycle operations using StackQL (using the `EXEC` method).  

```yaml
- name: stop running instances using stackql-exec
  uses: stackql/stackql-exec@v1.3.1
  with:
    query_file_path: './stackql/scripts/stop-instances/stop-instances.iql'
    data_file_path: './stackql/data/vars.jsonnet'
    vars: GOOGLE_PROJECT=${{ env.GOOGLE_PROJECT }},GOOGLE_ZONE=${{ env.GOOGLE_ZONE }}    
  env:
    GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }} 
    GOOGLE_PROJECT: ${{ vars.GOOGLE_PROJECT }}
    GOOGLE_ZONE: ${{ vars.GOOGLE_ZONE }}       
```

### check if we have 4 instances using `stackql-assert`

This step demonstrates how to use the [__`stackql-assert`__](https://github.com/marketplace/actions/stackql-studios-stackql-assert) action to run a StackQL `SELECT` query and compare the actual result count with an expected result count, if there is a discrepancy then the action will fail.  

```yaml
- name: check if we have 4 instances using stackql-assert
  uses: stackql/stackql-assert@v1.3.1
  with:
    test_query_file_path: './stackql/scripts/check-instances.iql'
    data_file_path: './stackql/data/vars.jsonnet'
    vars: GOOGLE_PROJECT=${{ env.GOOGLE_PROJECT }},GOOGLE_ZONE=${{ env.GOOGLE_ZONE }}    
    expected_rows: 4
  env:
    GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }} 
    GOOGLE_PROJECT: ${{ vars.GOOGLE_PROJECT }}
    GOOGLE_ZONE: ${{ vars.GOOGLE_ZONE }}    
```

### check `terraform` deployment using `stackql-assert`

This step demonstrates how to use the `stackql-assert` action in a `terraform` deployment pipeline to run a StackQL `SELECT` query and compare the actual result with an expected result after a `terraform` deployment.  This can test specific configuration properties of the resource (for compliance or policy enforcement) or just the existence of the resource.

```yaml
- name: check terraform deployment using stackql-assert
  uses: stackql/stackql-assert@v1.3.1
  with:
    test_query_file_path: './stackql/scripts/check-terraform-instances/check-terraform-instances.iql'
    expected_results_str: '[{"name":"terraform-test-1","name":"terraform-test-2"}]'
  env:
    GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }} 
```

### run a compliance (CSPM) check using `stackql-assert`

This step demonstrates how to use the `stackql-assert` action to run a compliance check in a GitHub Actions Workflow.

```yaml
- name: run a compliance check using stackql-assert
  uses: stackql/stackql-assert@v1.3.1
  with:
    test_query: |
      SELECT
        name,
        labels,
        metadata
      FROM
        gcp_compute_instance
      WHERE
        metadata.items[0].value = 'test'
    expected_rows: 0
  env:
    GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }} 
```

See [`.github/workflows/stackql.yml`](.github/workflows/stackql.yml) for the complete workflow file.
