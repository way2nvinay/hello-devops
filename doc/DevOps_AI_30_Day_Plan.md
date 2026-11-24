# DevOps with AI: Tools, Roadmap, Resources, and 30-Day Plan

Assumes a beginner to intermediate learner with about 1–2 hours a day. Each day: 30–40 min of learning, then hands-on practice.

---

## 1. Tools to Learn

**Foundations**
1. **Linux and the shell (bash)**: the base for almost all DevOps work
2. **Git and GitHub**: version control, branches, pull requests
3. **Docker**: containers, images, Compose

**Core DevOps**
4. **Kubernetes (kubectl, Helm)**: container orchestration
5. **Terraform**: infrastructure as code (IaC)
6. **GitHub Actions**: CI/CD pipelines
7. **Ansible**: configuration management
8. **Argo CD**: GitOps deployments to Kubernetes

**Observability and Security**
9. **Prometheus + Grafana**: metrics and dashboards
10. **OpenTelemetry**: tracing and logging
11. **Trivy and Checkov**: container and IaC security scanning

**AI-Assisted DevOps**
12. **GitHub Copilot / Claude Code**: AI assistants for pipelines, scripts, and IaC
13. **k8sgpt**: AI-assisted diagnosis of Kubernetes problems
14. **MCP (Model Context Protocol)**: connecting AI assistants to tools such as Kubernetes, GitHub, and Terraform
15. **AI for incident response and log analysis**: using LLMs to summarize logs and suggest root causes

---

## 2. Roadmap (4 Phases)

| Phase | Weeks | Focus | Milestone |
|---|---|---|---|
| 1. Foundations | 1 | Linux, Git, shell scripting | Automate a task with a bash script |
| 2. Containers | 2 | Docker, Docker Compose | Containerize a small app with a database |
| 3. Orchestration and IaC | 3 | Kubernetes, Helm, Terraform | Deploy the app to a local cluster; provision infra with Terraform |
| 4. CI/CD, Observability, AI | 4 | GitHub Actions, Prometheus/Grafana, AI tools | Full pipeline: build, scan, deploy, monitor |

---

## 3. Learning Resources (with Links)

**Linux and Git**
- Linux Journey: https://linuxjourney.com
- OverTheWire Bandit (free Linux challenges): https://overthewire.org/wargames/bandit
- Learn Git Branching: https://learngitbranching.js.org

**Docker**
- Docker official guides: https://docs.docker.com/get-started
- Play with Docker (free browser labs): https://labs.play-with-docker.com

**Kubernetes**
- Official tutorials: https://kubernetes.io/docs/tutorials
- Killercoda (free interactive labs): https://killercoda.com
- Kubernetes The Hard Way: https://github.com/kelseyhightower/kubernetes-the-hard-way

**Terraform**
- HashiCorp tutorials: https://developer.hashicorp.com/terraform/tutorials
- Book: *Terraform: Up & Running* by Yevgeniy Brikman

**CI/CD and GitOps**
- GitHub Actions docs: https://docs.github.com/actions
- Argo CD docs: https://argo-cd.readthedocs.io

**Observability**
- Prometheus docs: https://prometheus.io/docs
- Grafana tutorials: https://grafana.com/tutorials
- OpenTelemetry docs: https://opentelemetry.io/docs

**Security**
- Trivy docs: https://trivy.dev
- Checkov docs: https://www.checkov.io

**AI-Assisted DevOps**
- Claude Code docs: https://docs.claude.com (also https://code.claude.com/docs)
- GitHub Copilot docs: https://docs.github.com/copilot
- MCP docs: https://modelcontextprotocol.io
- k8sgpt: https://k8sgpt.ai

**Video courses (free)**
- TechWorld with Nana (YouTube): Docker, Kubernetes, and Terraform crash courses
- freeCodeCamp (YouTube): full DevOps and Kubernetes courses

**Reference reading**
- *Site Reliability Engineering* (Google, free online): https://sre.google/books

---

## 4. 30-Day Plan

### Week 1: Foundations (Linux, Git, Scripting)

| Day | Topic | Practice |
|---|---|---|
| 1 | Linux basics, file system, permissions | Navigate and manage files with the shell |
| 2 | Processes, users, services, logs | Inspect running processes and `journalctl` logs |
| 3 | Bash scripting basics | Script that backs up a folder |
| 4 | Bash control flow and functions | Script that monitors disk usage and alerts |
| 5 | Git basics: commit, branch, merge | Create a repo with feature branches |
| 6 | GitHub: pull requests, remotes | Open and merge a PR on GitHub |
| 7 | Review and mini project | Automate a folder cleanup and push to GitHub |

### Week 2: Containers (Docker)

| Day | Topic | Practice |
|---|---|---|
| 8 | Docker concepts, images, containers | Run nginx and a Python container |
| 9 | Dockerfile and building images | Containerize a simple Flask or Node app |
| 10 | Volumes, networks, ports | Persist data and connect two containers |
| 11 | Docker Compose | Run app + Postgres + Redis with Compose |
| 12 | Image optimization (multi-stage builds) | Shrink an image by more than 50% |
| 13 | Docker security basics | Scan an image with Trivy |
| 14 | Mini project | Full containerized stack, pushed to a registry |

### Week 3: Orchestration and Infrastructure as Code (Kubernetes, Terraform)

| Day | Topic | Practice |
|---|---|---|
| 15 | Kubernetes architecture, pods, kubectl | Set up a local cluster (kind or minikube) |
| 16 | Deployments, services, ConfigMaps | Deploy the Week 2 app |
| 17 | Ingress, scaling, health checks | Scale a deployment; add liveness probes |
| 18 | Helm charts | Package the app as a Helm chart |
| 19 | Terraform basics: providers, resources, state | Create a local or cloud resource |
| 20 | Terraform modules and variables | Refactor into reusable modules |
| 21 | Mini project | Provision infra with Terraform; deploy app to Kubernetes |

### Week 4: CI/CD, Observability, and AI-Assisted DevOps

| Day | Topic | Practice |
|---|---|---|
| 22 | GitHub Actions basics | Workflow that runs tests on each push |
| 23 | Build and push Docker images in CI | Pipeline that publishes to a registry |
| 24 | Security scanning in CI | Add Trivy and Checkov to the pipeline |
| 25 | Prometheus and Grafana | Monitor the app with a dashboard |
| 26 | OpenTelemetry and logging | Add tracing and centralized logs |
| 27 | AI for DevOps: Copilot / Claude Code | Use AI to write a pipeline and a Terraform module; review the output |
| 28 | k8sgpt and AI-assisted troubleshooting | Break a deployment on purpose; diagnose it with k8sgpt |
| 29 | MCP and AI agents for ops | Connect an AI assistant to your cluster or GitHub via MCP |
| 30 | Capstone | End-to-end project (below) |

**Day 30 capstone:** A small app that is containerized, provisioned with Terraform, deployed to Kubernetes, built and scanned by GitHub Actions, monitored in Grafana, and diagnosed with an AI tool when something breaks. Publish it in a public GitHub repo with a README that explains the architecture.

---

## 5. Tips
- Spend at least half your time on hands-on labs.
- On free cloud tiers, tear down resources after each session to avoid charges.
- Keep a learning log in your repo: what broke and how you fixed it.

---

## 6. Reference Links (Quick List)

| Topic | Link |
|---|---|
| Linux Journey | https://linuxjourney.com |
| OverTheWire Bandit | https://overthewire.org/wargames/bandit |
| Learn Git Branching | https://learngitbranching.js.org |
| Docker docs | https://docs.docker.com/get-started |
| Play with Docker | https://labs.play-with-docker.com |
| Kubernetes tutorials | https://kubernetes.io/docs/tutorials |
| Killercoda | https://killercoda.com |
| Kubernetes The Hard Way | https://github.com/kelseyhightower/kubernetes-the-hard-way |
| Terraform tutorials | https://developer.hashicorp.com/terraform/tutorials |
| GitHub Actions docs | https://docs.github.com/actions |
| Argo CD docs | https://argo-cd.readthedocs.io |
| Prometheus docs | https://prometheus.io/docs |
| Grafana tutorials | https://grafana.com/tutorials |
| OpenTelemetry docs | https://opentelemetry.io/docs |
| Trivy | https://trivy.dev |
| Checkov | https://www.checkov.io |
| Claude Code docs | https://docs.claude.com |
| GitHub Copilot docs | https://docs.github.com/copilot |
| MCP docs | https://modelcontextprotocol.io |
| k8sgpt | https://k8sgpt.ai |
| Google SRE book | https://sre.google/books |

*Note: Links were compiled from memory. Confirm each one loads before relying on it, since sites occasionally move pages.*
