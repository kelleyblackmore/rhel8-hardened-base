# RHEL 8 Hardened Base Container Image

A production-ready, security-hardened Red Hat Enterprise Linux 8 (UBI8) base container image with comprehensive STIG compliance, automated vulnerability scanning, and enterprise-grade CI/CD pipeline.

## Security Features

### STIG Compliance
- **Comprehensive RHEL 8 STIG Implementation**: Full coverage of DoD Security Technical Implementation Guide controls
- **Account Management**: Secure user policies, password controls, and access restrictions
- **File System Security**: Proper permissions, SUID/SGID auditing, and ownership controls  
- **Network Hardening**: SSH security, service management, and protocol restrictions
- **Audit & Logging**: Complete audit rules and log retention policies
- **System Maintenance**: Security updates, kernel parameters, and attack surface reduction

### Automated Security Scanning
- **Multi-layer Vulnerability Scanning**: Container images, filesystems, and dependencies via Trivy
- **Secret Detection**: Repository-wide secret scanning with GitLeaks
- **SBOM Generation**: CycloneDX format Software Bill of Materials with change tracking
- **Vulnerability Blocking**: Critical vulnerabilities automatically fail PR merges
- **Dual Scan Modes**: Report-only for development, enforcement for production merges

### Container Security Best Practices
- **Non-root by default**: Runs as UID 10001 with OpenShift-compatible permissions
- **Minimal attack surface**: Only essential packages (ca-certificates, tzdata, jq)
- **Red Hat UBI8 base**: Official Red Hat Universal Base Image for licensing compliance
- **Clean builds**: No package caches, temporary files, or development tools

## STIG Controls Implemented

| Category | STIG Controls | Status |
|----------|---------------|--------|
| Account Management | RHEL-08-010xxx series | Complete |
| System Maintenance | RHEL-08-020xxx series | Complete |
| Audit & Logging | RHEL-08-030xxx series | Complete |
| Network Security | RHEL-08-040xxx series | Complete |

## Quick Start

### Using as a Base Image

Create your application Dockerfile:

```dockerfile
FROM ghcr.io/kelleyblackmore/rhel8-hardened-base:latest

# Your application-specific setup
COPY app/ /app/
RUN dnf -y install python3 && dnf clean all

# Continue running as non-root
USER 10001
CMD ["python3", "app.py"]
```

### Pulling the Image

```bash
# Latest version
podman pull ghcr.io/kelleyblackmore/rhel8-hardened-base:latest

# Specific version
podman pull ghcr.io/kelleyblackmore/rhel8-hardened-base:0.0.1

# Run interactively for testing
podman run -it ghcr.io/kelleyblackmore/rhel8-hardened-base:latest /bin/bash
```

## Building from Source

```bash
# Clone repository
git clone https://github.com/kelleyblackmore/rhel8-hardened-base.git
cd rhel8-hardened-base

# Build locally with consistent naming
podman build -t localhost/rhel8-hardened:latest .

# Verify the build
podman images localhost/rhel8-hardened

# Test run the container
podman run -it localhost/rhel8-hardened:latest /bin/bash
```

### Local Security Testing

```bash
# Scan the locally built container image
trivy image localhost/rhel8-hardened:latest

# Scan filesystem before building
trivy fs .

# Check for secrets in repository
gitleaks detect --source .

# Run with specific vulnerability severities
trivy image --severity HIGH,CRITICAL localhost/rhel8-hardened:latest

# Generate detailed report
trivy image --format json -o trivy-report.json localhost/rhel8-hardened:latest
```

## CI/CD Pipeline Features

### Automated Workflows

1. **Build & Push**: Automatic versioning, building, and publishing to GitHub Container Registry
2. **Security Scanning**: Comprehensive vulnerability and secret scanning on every commit  
3. **SBOM Generation**: Software Bill of Materials creation and change tracking

### Version Management
- **Semantic Versioning**: Auto-increment patch versions starting from 0.0.1
- **Git Tag Integration**: Automatic tag creation and GitHub releases
- **Multi-format Tags**: `latest`, `0.0.1`, `main-abc123` for different use cases

### Security Gates
- **PR Protection**: Critical vulnerabilities block merges to main branch
- **Continuous Monitoring**: Daily security scans and SBOM updates
- **Artifact Retention**: 365-day retention for versioned images and security reports

## Image Variants & Tags

| Tag Pattern | Use Case | Example |
|-------------|----------|---------|
| `latest` | Production latest | `ghcr.io/.../rhel8-hardened-base:latest` |
| `X.Y.Z` | Specific version | `ghcr.io/.../rhel8-hardened-base:0.0.1` |
| `main-SHA` | Development | `ghcr.io/.../rhel8-hardened-base:main-a1b2c3d` |
| `pr-N` | Pull request testing | `ghcr.io/.../rhel8-hardened-base:pr-123` |

## Security Scanning Results

Security scan results are automatically uploaded to:
- **GitHub Security Tab**: Vulnerability alerts and advisories
- **Workflow Artifacts**: Detailed Trivy reports and SBOM files
- **GitHub Releases**: Security summaries for each version

### Local Security Testing

```bash
# Scan the locally built container image
trivy image localhost/rhel8-hardened:latest

# Scan filesystem before building
trivy fs .

# Check for secrets in repository
gitleaks detect --source .

# Run with specific vulnerability severities
trivy image --severity HIGH,CRITICAL localhost/rhel8-hardened:latest

# Generate detailed report
trivy image --format json -o trivy-report.json localhost/rhel8-hardened:latest
```

##  Repository Structure

```
├── .github/
│   ├── build-and-push.yml      # Main CI/CD pipeline
│   ├── container-scan.yml      # Security scanning workflow  
│   └── sbom-check.yml          # SBOM generation and tracking
├── scripts/
│   ├── apply-all-stig.sh       # Master hardening script
│   ├── stig-account-management.sh
│   ├── stig-filesystem.sh
│   ├── stig-network.sh
│   ├── stig-audit-logging.sh
│   └── stig-system-maintenance.sh
├── Containerfile               # Main container build definition
└── README.md                   # This file
```

## 🔧 Customization

### Adding Your Application

```dockerfile
FROM ghcr.io/kelleyblackmore/rhel8-hardened-base:latest

# Install additional packages if needed
USER root
RUN dnf -y install nodejs npm && dnf clean all

# Copy application
COPY --chown=10001:0 package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY --chown=10001:0 src/ ./src/

# Return to non-root user
USER 10001
EXPOSE 3000
CMD ["node", "src/index.js"]
```

### Custom STIG Scripts

Add your own hardening scripts to the `scripts/` directory and modify [scripts/apply-all-stig.sh](scripts/apply-all-stig.sh):

```bash
# Add to STIG_SCRIPTS array
STIG_SCRIPTS=(
    "stig-system-maintenance.sh"
    "stig-account-management.sh"
    "stig-filesystem.sh"
    "stig-network.sh"
    "stig-audit-logging.sh"
    "your-custom-stig.sh"        # Add your script here
)
```

## Enterprise Integration

### OpenShift Compatibility
- Runs with arbitrary UIDs (OpenShift random UID assignment)
- Group 0 permissions for file system access
- No privileged operations required

### Compliance Reporting
- STIG control mappings documented in each script
- Audit trails via Git history and workflow artifacts
- SBOM generation for supply chain compliance

### Registry Integration
```bash
# Configure for your enterprise registry
export REGISTRY="your-registry.company.com"
export IMAGE_NAME="platform/rhel8-hardened-base"

# Retag and push
podman tag ghcr.io/kelleyblackmore/rhel8-hardened-base:latest $REGISTRY/$IMAGE_NAME:latest
podman push $REGISTRY/$IMAGE_NAME:latest
```

## Troubleshooting

### Common Issues

**Permission Denied Errors**
```bash
# Ensure proper group permissions
RUN chmod -R g=u /app && chown -R 10001:0 /app
```

**Package Installation Failures**
```bash
# Switch to root for package management, then back to non-root
USER root
RUN dnf -y install package-name && dnf clean all
USER 10001
```

**Container Won't Start**
```bash
# Check user permissions
podman run -it --user 10001 rhel8-hardened:latest /bin/bash
```

### Security Scan Failures

1. **Critical Vulnerabilities**: Update base image and rebuild
2. **False Positives**: Add to `.trivyignore` file with justification
3. **Secret Detection**: Remove secrets and rotate credentials

## References

- [RHEL 8 STIG Guide](https://www.stigviewer.com/stig/red_hat_enterprise_linux_8/)
- [Red Hat Universal Base Images](https://catalog.redhat.com/software/containers/ubi8/ubi/5c359854d70cc534b3a3784e)
- [OpenShift Container Platform Security](https://docs.openshift.com/container-platform/latest/security/)
- [Container Security Best Practices](https://cloud.google.com/architecture/best-practices-for-building-containers)

##  License


This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
base image is covered under the Red Hat Universal Base Image (UBI) license, which allows for free use and distribution in compliance with their terms. 

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-security`)
3. Commit your changes (`git commit -m 'Add security feature'`)
4. Push to the branch (`git push origin feature/amazing-security`)
5. Open a Pull Request

All contributions must pass security scans and maintain STIG compliance.