# RHEL 8 Hardened Base Image Tests

This directory contains tests to validate the functionality and security compliance of the RHEL 8 hardened base image.

## Test Overview

The test suite validates:
- **User Security**: Ensures the image runs as non-root user (STIG compliance)
- **Environment Variables**: Validates required environment settings
- **Package Installation**: Tests Python3 and jq availability
- **File Permissions**: Checks critical system file permissions

## Running Tests

### Prerequisites

1. Build the hardened base image first:
   ```bash
   cd /path/to/rhel8-hardened-base
   docker build -f Containerfile -t localhost/rhel8-hardened:latest .
   ```

### Quick Test

```bash
# From the tests directory
docker build -f Containerfile -t rhel8-hardened-test:latest . && \
docker run --rm rhel8-hardened-test:latest
```

### Individual Steps

1. **Build the test container:**
   ```bash
   cd tests/
   docker build -f Containerfile -t rhel8-hardened-test:latest .
   ```

2. **Run the validation tests:**
   ```bash
   docker run --rm rhel8-hardened-test:latest
   ```

## Test Results

Successful output should look like:
```
RHEL 8 Hardened Base Image Tests
=================================
Testing user security...
  Current UID: 10001
  Current GID: 0
  PASS: Running as non-root user
  User name: appuser

Testing environment...
  PASS: LANG=C.UTF-8
  PASS: LC_ALL=C.UTF-8
  PASS: TZ=UTC

Testing installed packages...
  PASS: Python: Python 3.6.8
  PASS: jq: jq-1.6

Testing file permissions...
  PASS: /etc/passwd has correct permissions (644)
  PASS: /app exists and is accessible

Test Results: 4/4 tests passed
All tests passed! Base image is working correctly.
```

## Security Validation

The tests specifically validate STIG compliance requirements:
- **Non-root execution**: Container runs as `appuser` (UID 10001)
- **Proper environment**: UTF-8 locale and UTC timezone
- **File permissions**: System files have correct permissions
- **Working directory**: `/app` is accessible to the application user

## Troubleshooting

### "unable to find user app" error
- The base image uses `appuser`, not `app`
- Ensure the test Containerfile uses `USER appuser`

### "Python3 test failed" error  
- Check that Python 3 is installed in the base image
- Verify the subprocess call compatibility with Python 3.6+

### "Docker can't find localhost/rhel8-hardened:latest"
- Build the base image first with the correct tag
- Or update the test to use an available image tag

## Files

- `Containerfile` - Test container definition
- `test_hello.py` - Python validation script
- `README.md` - This documentation