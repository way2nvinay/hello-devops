# Capstone Project: "hello-devops" (Beginner Step-by-Step Guide)

This project uses every tool from the 30-day plan. You build one small web app, then package it, deploy it, automate it, monitor it, and fix it when it breaks.

**You need no cloud account and no money.** Everything runs on your Windows laptop.

---

## 0. What You Will Build

```
You write code  →  Docker packages it  →  GitHub Actions tests & scans it
      →  Kubernetes runs it (on your laptop, via kind)
      →  Terraform creates the namespace   |   Ansible checks your tools
      →  Argo CD keeps it in sync with GitHub
      →  Prometheus + Grafana watch it
      →  k8sgpt / AI helps you fix it when it breaks
```

| # | Tool | What it does in this project |
|---|---|---|
| 1 | Linux / bash | Runs all commands (inside WSL) |
| 2 | Git & GitHub | Stores code, triggers CI |
| 3 | Docker | Packages the app into an image |
| 4 | Kubernetes (kubectl) | Runs the app |
| 5 | kind | A Kubernetes cluster inside Docker, on your laptop |
| 6 | Helm | Installs Prometheus and Grafana |
| 7 | Terraform | Creates the Kubernetes namespace as code |
| 8 | Ansible | Checks that all tools are installed correctly |
| 9 | GitHub Actions | Runs tests, security scans, builds and pushes the image |
| 10 | Trivy & Checkov | Security scanning of the image and Terraform code |
| 11 | Argo CD | Deploys to Kubernetes automatically from Git (GitOps) |
| 12 | Prometheus + Grafana | Metrics and dashboards |
| 13 | OpenTelemetry | Optional stretch step (tracing) |
| 14 | k8sgpt | Explains what is wrong in your cluster |
| 15 | Claude Code / Copilot | AI helper for writing and reviewing files |

---

## 1. One-Time Setup (Windows)

Do these once. Each step says what to check.

### 1.1 Install WSL2 with Ubuntu
Open **PowerShell as Administrator**:
```powershell
wsl --install -d Ubuntu
```
Restart the PC. Open **Ubuntu** from the Start menu and create a username and password.
*Check:* `lsb_release -a` shows Ubuntu.

### 1.2 Install Docker Desktop
1. Download from https://www.docker.com/products/docker-desktop
2. Settings → **General**: tick "Use the WSL 2 based engine"
3. Settings → **Resources → WSL Integration**: turn on **Ubuntu**
4. Settings → **Resources**: give Docker at least **6 GB memory** (needed for Prometheus and Grafana)

*Check (in Ubuntu):* `docker run hello-world` prints "Hello from Docker!"

### 1.3 Install VS Code
Download from https://code.visualstudio.com. Install the **WSL** extension (Microsoft). Later, open the project with `code .` from inside Ubuntu.

### 1.4 Install the command-line tools inside Ubuntu
Copy and run each block in the Ubuntu terminal.

```bash
# Basics
sudo apt update && sudo apt install -y git curl unzip python3 python3-pip python3-venv ansible

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl

# kind (Kubernetes in Docker)
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
sudo install -m 0755 kind /usr/local/bin/kind

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Terraform: follow the Ubuntu steps at https://developer.hashicorp.com/terraform/install
# Trivy (Option A: official apt repository)
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install -y trivy
# Trivy (Option B, if Option A fails): install script
# curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
# k8sgpt: follow https://docs.k8sgpt.ai/getting-started/installation/
# Checkov (Python tool), installed with pipx so it lands on your PATH
sudo apt install -y pipx
pipx install checkov
pipx ensurepath
source ~/.bashrc
```

*Check:* each command prints a version:
```bash
git --version
kubectl version --client
kind version
helm version
terraform version
trivy --version
checkov --version
ansible --version
```

*Tip:* run each line on its own. If one tool is missing, the others still print.

### 1.5 Create accounts
- **GitHub** (free): https://github.com. Used for code, CI, and the container registry.
- **Git identity** (one time):
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

---

## 2. Create the Project Folder

Pick one location and keep everything inside it:
```bash
mkdir -p ~/hello-devops && cd ~/hello-devops
git init -b main
mkdir -p app k8s terraform argocd ansible .github/workflows
```

Final layout (you will build each part):
```
hello-devops/
├── app/                  # the Python web app + Dockerfile + tests
├── k8s/                  # Kubernetes manifests (Deployment, Service)
├── terraform/            # infrastructure as code
├── argocd/               # Argo CD Application (GitOps)
├── ansible/              # tool-check playbook
├── .github/workflows/    # GitHub Actions CI pipeline
└── README.md
```

---

## 3. Step 1: The Application

### 3.1 Write the app
Create `app/app.py`:
```python
from flask import Flask, jsonify
import os

app = Flask(__name__)
VERSION = os.getenv("APP_VERSION", "1.0.0")

@app.route("/")
def home():
    return jsonify(message="Hello from hello-devops!", version=VERSION)

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
```

Create `app/requirements.txt`:
```text
flask==3.0.3
gunicorn==22.0.0
pytest==8.3.2
```

Create `app/test_app.py`:
```python
from app import app

def test_health():
    client = app.test_client()
    assert client.get("/health").status_code == 200

def test_home():
    client = app.test_client()
    assert client.get("/").get_json()["message"] == "Hello from hello-devops!"
```

### 3.2 Run it locally
```bash
cd ~/hello-devops/app
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
pytest -q          # should print: 2 passed
python app.py      # open http://localhost:8080 in your Windows browser
```
Press `Ctrl+C` to stop.

### 3.3 Containerize it (Docker)
Create `app/Dockerfile`:
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV APP_VERSION=1.0.0
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
```

Create `app/.dockerignore`:
```text
.venv
__pycache__
*.pyc
```

Build and run:
```bash
cd ~/hello-devops/app
docker build -t hello-devops:1.0 .
docker run -d -p 8080:8080 --name hello hello-devops:1.0
curl http://localhost:8080/health      # {"status":"ok"}
docker rm -f hello
```

*Why:* the image runs the same way on any machine, which is the point of containers.

### 3.4 Put the code on GitHub
1. On GitHub, create a **public** repository named `hello-devops` (do not add a README).
2. In Ubuntu:
```bash
cd ~/hello-devops
printf "__pycache__/\n.venv/\n*.pyc\n.terraform/\n*.tfstate\n*.tfstate.*\n" > .gitignore
git add . && git commit -m "Initial app and Dockerfile"
git remote add origin https://github.com/YOUR-USERNAME/hello-devops.git
git push -u origin main
```
Replace `YOUR-USERNAME`.

**Signing in to GitHub from WSL.** GitHub no longer accepts your account password for `git push`. Pick one option:

*Option A: GitHub CLI (recommended).* Install it and sign in:
```bash
sudo apt install -y gh
gh auth login
```
Choose **GitHub.com**, **HTTPS**, then **Login with a web browser**. WSL cannot open a browser, so the message "Failed opening a web browser" is expected. Open https://github.com/login/device in your **Windows** browser, type the one-time code shown in the terminal, and click **Authorize**. Then run `git push` again.

*Option B: Personal Access Token.* On GitHub, go to **Settings → Developer settings → Personal access tokens → Tokens (classic)**, create a token with the **repo** scope, and copy it. Run `git push`, and paste the token as the password. Don't share the token.

**Before the push, the repository must exist.** Create `hello-devops` on GitHub (section 3.4, step 1). If you see `Repository not found`, the repo has not been created yet.

---

## 4. Step 2: Kubernetes on Your Laptop (kind + kubectl)

### 4.1 Create a cluster
```bash
kind create cluster --name devops-lab
kubectl cluster-info --context kind-devops-lab
kubectl get nodes          # one node, STATUS Ready
```

### 4.2 Load your image into the cluster
kind runs in its own world, so give it your image:
```bash
kind load docker-image hello-devops:1.0 --name devops-lab
```

### 4.3 Write the manifests
Create `k8s/deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-devops
  labels:
    app: hello-devops
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-devops
  template:
    metadata:
      labels:
        app: hello-devops
    spec:
      containers:
        - name: hello-devops
          image: hello-devops:1.0
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 5
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 3
```

Create `k8s/service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-devops
spec:
  selector:
    app: hello-devops
  ports:
    - port: 80
      targetPort: 8080
```

### 4.4 Deploy and test
```bash
kubectl create namespace hello-devops
kubectl apply -n hello-devops -f k8s/
kubectl get pods -n hello-devops            # 2 pods, STATUS Running
kubectl port-forward -n hello-devops svc/hello-devops 8081:80
```
Open http://localhost:8081 in your browser. Press `Ctrl+C` to stop the port-forward.

*Learn:* a **Deployment** keeps 2 copies alive; a **Service** gives them one stable address; **probes** tell Kubernetes when the app is healthy.

---

## 5. Step 3: Helm (Install Monitoring)

Helm installs complex apps from ready-made packages called charts. Here it installs Prometheus and Grafana.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace
kubectl get pods -n monitoring -w       # wait until pods are Running (Ctrl+C to exit)
```

*Check:* all pods are `Running`. This can take 3–5 minutes.

Once everything is up, stop the watch (`Ctrl+C`) and confirm with a fresh list:
```bash
kubectl get pods -n monitoring
```

Get the Grafana admin password (use this command; it is the one Helm prints):
```bash
kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode; echo
```

Open Grafana. Run the port-forward in a **second Ubuntu window** and leave it running:
```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```
Then open http://localhost:3000 in your Windows browser. Log in as `admin` with the password above.

---

## 6. Step 4: Terraform (Infrastructure as Code)

Terraform describes infrastructure in files, so it can be recreated anytime. Here it manages the Kubernetes namespace.

Create `terraform/main.tf`:
```hcl
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-devops-lab"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "hello-devops-tf"
    labels = {
      managed-by = "terraform"
      project    = "hello-devops"
    }
  }
}
```

Run it:
```bash
cd ~/hello-devops/terraform
terraform init      # downloads the provider
terraform plan      # shows what WILL change (nothing is changed yet)
```
`terraform plan` should end with `Plan: 1 to add, 0 to change, 0 to destroy.`

Apply it:
```bash
terraform apply     # type "yes"
kubectl get ns hello-devops-tf
```
You should see `hello-devops-tf   Active`.

*Learn:* `plan` before `apply` is the most important habit in Terraform.

**Optional practice:** remove the namespace, then bring it back:
```bash
terraform destroy   # type "yes"
terraform apply     # type "yes" to recreate it
```

**Save the Terraform files to GitHub.** Terraform writes `terraform.tfstate` in this folder. It contains secrets and must never be committed. The `.gitignore` from section 3.4 already excludes it. Before committing, check it:
```bash
cd ~/hello-devops
git status
```
`terraform.tfstate` must not appear in the list. Then commit and push:
```bash
git add terraform .gitignore
git commit -m "Add Terraform config"
git push
```

---

## 7. Step 5: Ansible (Check Your Tools)

Ansible automates tasks. Here a playbook checks your tool installation, the same way you would configure a real server.

Create `ansible/check_tools.yml`:
```yaml
- name: Check DevOps tools on this machine
  hosts: localhost
  connection: local
  tasks:
    - name: Check each tool is installed
      ansible.builtin.command: "{{ item }}"
      loop:
        - docker --version
        - kubectl version --client
        - kind version
        - helm version
        - terraform version
        - trivy --version
      register: tool_check
      changed_when: false

    - name: Show results
      ansible.builtin.debug:
        msg: "{{ item.stdout_lines[0] | default('missing') }}"
      loop: "{{ tool_check.results }}"
```

Run it:
```bash
cd ~/hello-devops/ansible
ansible-playbook check_tools.yml
```
*Check:* the play finishes with `failed=0`.

---

## 8. Step 6: GitHub Actions (CI Pipeline)

Every push to GitHub will test the code, scan it for security problems, and build and publish the image automatically.

Create `.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read
  packages: write        # needed to publish to GitHub Container Registry

jobs:
  test-and-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Run unit tests
        working-directory: app
        run: |
          pip install -r requirements.txt
          pytest -q

      - name: Security scan of Terraform (Checkov)
        run: |
          pip install checkov
          checkov -d terraform --quiet || true   # warn-only while learning

  build-and-push:
    needs: test-and-scan
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push image
        uses: docker/build-push-action@v6
        with:
          context: app
          push: true
          tags: ghcr.io/${{ github.repository_owner }}/hello-devops:${{ github.sha }}

      - name: Scan image for vulnerabilities (Trivy)
        # Install Trivy directly. The trivy-action has a broken dependency, so we avoid it.
        run: |
          curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
          trivy image --severity CRITICAL,HIGH --exit-code 0 ghcr.io/${{ github.repository_owner }}/hello-devops:${{ github.sha }}
```

**Before the first run, check the workflow permissions.** Without this, the image push fails. On GitHub, open your repo → **Settings → Actions → General → Workflow permissions**, select **Read and write permissions**, and click **Save**.

Commit and push:
```bash
cd ~/hello-devops
git add . && git commit -m "Add CI pipeline" && git push
```
On GitHub, open the **Actions** tab and watch the run. Green means it passed.

If `build-and-push` fails, click the red step and read its log. Common causes:
- **Unable to resolve action**: the version tag is wrong. Use the Trivy install step in this guide, which installs Trivy directly.
- **Permission denied on push**: the workflow permissions above are not set.

*Note:* the image is now in `ghcr.io/YOUR-USERNAME/hello-devops`. Check the **Packages** section on your GitHub profile. If you want to make it public, go to the package settings.

---

## 9. Step 7: Security Scanning Locally (Trivy and Checkov)

```bash
# Image scan: lists known vulnerabilities in your image
trivy image hello-devops:1.0

# Terraform scan: finds insecure configuration.
# The env -u part clears a proxy variable that makes checkov crash on some WSL setups.
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy checkov -d ~/hello-devops/terraform
```
*Note:* this file has only a Kubernetes namespace, which Checkov's Terraform checks mostly ignore. A clean run with no pass/fail summary is normal here.

*Learn:* read the list, fix the easy ones (for example, upgrade a base image), and note the rest. Real teams do exactly this.

---

## 10. Step 8: Argo CD (GitOps Deployment)

GitOps means Git is the source of truth. Argo CD watches your repo and makes the cluster match it.

### 10.1 Install Argo CD
```bash
kubectl create namespace argocd
# Server-side apply: needed because the ApplicationSet CRD is too large for a normal apply
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
```

### 10.2 Open the Argo CD dashboard
```bash
kubectl port-forward -n argocd svc/argocd-server 8443:443
```
Open https://localhost:8443 (accept the warning). Username: `admin`. Get the password in a second Ubuntu terminal:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### 10.3 Connect it to your repo
Create `argocd/application.yaml` (replace `YOUR-USERNAME`):
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: hello-devops
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR-USERNAME/hello-devops.git
    targetRevision: main
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: hello-devops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
Commit it, then apply it once:
```bash
git add argocd && git commit -m "Add Argo CD app" && git push
kubectl apply -n argocd -f argocd/application.yaml
```
In the dashboard, **hello-devops** shows as Synced and Healthy.

*Try it:* change `replicas: 2` to `replicas: 3` in `k8s/deployment.yaml`, commit, and push. Within a few minutes Argo CD scales the app to 3 pods without you running any command.

---

## 11. Step 9: Monitoring (Prometheus and Grafana)

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```
Open http://localhost:3000. Username: `admin`. Password:
```bash
kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d; echo
```
Go to **Dashboards** and open a built-in one, such as **Kubernetes / Compute Resources / Namespace (Pods)**. Choose the `hello-devops` namespace to see your app's CPU and memory.

*Learn:* Prometheus collects numbers, Grafana draws them. Add a Prometheus alert rule as a stretch goal.

---

## 12. Step 10: OpenTelemetry (Optional Stretch)

OpenTelemetry records the path of each request across services. For this beginner project, read the basics first at https://opentelemetry.io/docs/languages/python/getting-started/ and try the Flask auto-instrumentation example once the core project works.

---

## 13. Step 11: AI-Assisted Operations

### 13.1 Use an AI assistant to write and review
Open the project in VS Code (`code ~/hello-devops`). Ask Claude Code or GitHub Copilot things like:
- "Review `k8s/deployment.yaml` for beginner mistakes and explain each fix."
- "Explain what `terraform plan` output means for this file."
- "Write a GitHub Actions step that fails the build when Trivy finds CRITICAL issues."

**Rule:** read every change before you commit it, and never paste passwords or tokens into a chat.

### 13.2 Break it on purpose, then diagnose it with k8sgpt
Break the image name:
```bash
kubectl set image deployment/hello-devops hello-devops=hello-devops:9.9 -n hello-devops
kubectl get pods -n hello-devops      # ImagePullBackOff or ErrImagePull
```
Diagnose without an AI provider (works right away):
```bash
kubectl get events -n hello-devops --sort-by=.lastTimestamp | tail -10
kubectl describe pod -n hello-devops -l app=hello-devops | grep -A5 Events
```
The events show the cause, for example `Failed to pull image "hello-devops:9.9"`.

k8sgpt needs an AI provider before it can run. Without one, it fails with `AI provider openai not specified`. Set one up only if you choose to, since OpenAI keys cost money:
```bash
k8sgpt analyze --namespace hello-devops      # needs a provider set up with `k8sgpt auth`
```

*Note:* during a bad rollout, Kubernetes keeps the old pods running, so the app stays up. That is why the old pods were still `Running` in the test.
Fix it:
```bash
kubectl set image deployment/hello-devops hello-devops=hello-devops:1.0 -n hello-devops
kubectl get pods -n hello-devops      # Running again
```
*Note:* if Argo CD is running with `selfHeal`, it will also revert your broken change. Watch that happen in the dashboard. That is GitOps working.

### 13.3 Stretch: MCP
Once comfortable, connect an AI assistant to your cluster or GitHub through an MCP server. Start at https://modelcontextprotocol.io.

---

## 14. Final Checklist (Your Project Is Done When…)

- [ ] `pytest` passes locally
- [ ] `docker run` serves `/health`
- [ ] The app runs on kind and is reachable through port-forward
- [ ] Helm installed Prometheus and Grafana, and you can see a dashboard
- [ ] Terraform created the namespace (`plan` → `apply` → `destroy`)
- [ ] Ansible playbook finishes with no failures
- [ ] GitHub Actions is green on `main`
- [ ] Trivy and Checkov have run, and you noted the findings
- [ ] Argo CD shows `hello-devops` as Synced and Healthy
- [ ] You broke the app and fixed it with k8sgpt or an AI assistant
- [ ] README written (see below)

---

## 15. Write Your README

Put this in `~/hello-devops/README.md` and fill in the blanks in your own words:
```markdown
# hello-devops
A small Flask app deployed with DevOps tooling.

## Architecture
Code → Docker → GitHub Actions (test, scan, push to GHCR) → Argo CD → Kubernetes (kind)
Monitoring: Prometheus + Grafana (Helm). Infra: Terraform. Tool checks: Ansible.

## How to run
1. `docker build -t hello-devops:1.0 app`
2. `kind create cluster --name devops-lab`
3. `kubectl apply -n hello-devops -f k8s/`

## What I learned
- ...

## Problems I hit and how I fixed them
- ...
```

Push it to GitHub. This repository is your portfolio piece.

---

## 16. Troubleshooting (Common Beginner Problems)

| Problem | Fix |
|---|---|
| `docker: command not found` in Ubuntu | Open Docker Desktop, then WSL Integration → enable Ubuntu |
| `kind create cluster` fails | Check Docker Desktop is running and has 6 GB memory |
| Pod stuck in `ImagePullBackOff` | You forgot `kind load docker-image`, or the tag is wrong |
| Pod `CrashLoopBackOff` | `kubectl logs -n hello-devops <pod-name>` shows why |
| Port-forward says "address already in use" | Use another port, such as 8082 |
| Prometheus or Argo CD pods stay `Pending` | Increase Docker memory, or stop other containers |
| `git push` asks for a password | Use a GitHub Personal Access Token, or run `gh auth login` |
| `checkov` fails with `ProxySchemeUnknown` | A proxy variable is set without `http://`. Run `env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy checkov -d terraform` |
| Pods are fine but the Actions run fails on GHCR push | Settings → Actions → General → Workflow permissions → "Read and write" |

---

## 17. Cleanup (When You Are Finished)
```bash
kind delete cluster --name devops-lab
```
This removes the whole lab. Your code stays on GitHub.

---

## 18. Official Docs for Each Step
- Docker: https://docs.docker.com/get-started
- kind: https://kind.sigs.k8s.io
- Kubernetes: https://kubernetes.io/docs/tutorials
- Helm: https://helm.sh/docs
- Terraform: https://developer.hashicorp.com/terraform/tutorials
- Ansible: https://docs.ansible.com
- GitHub Actions: https://docs.github.com/actions
- Trivy: https://trivy.dev
- Checkov: https://www.checkov.io
- Argo CD: https://argo-cd.readthedocs.io
- Prometheus: https://prometheus.io/docs
- Grafana: https://grafana.com/tutorials
- OpenTelemetry: https://opentelemetry.io/docs
- k8sgpt: https://k8sgpt.ai
- MCP: https://modelcontextprotocol.io

*These links were compiled from memory. Check that each one loads before relying on it.*
