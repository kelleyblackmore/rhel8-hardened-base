#!/usr/bin/env python3
"""
Simple test script to validate the RHEL 8 hardened base image
"""

import os
import sys
import subprocess
import pwd

def test_user_security():
    """Test that we're running as non-root user"""
    print("Testing user security...")
    
    # Check current user
    current_uid = os.getuid()
    current_gid = os.getgid()
    
    print(f"  Current UID: {current_uid}")
    print(f"  Current GID: {current_gid}")
    
    if current_uid == 0:
        print("  FAIL: Running as root user!")
        return False
    else:
        print("  PASS: Running as non-root user")
    
    # Check user name
    try:
        user_name = pwd.getpwuid(current_uid).pw_name
        print(f"  User name: {user_name}")
    except KeyError:
        print("  WARNING: Could not resolve username")
    
    return True

def test_environment():
    """Test environment variables"""
    print("\nTesting environment...")
    
    required_vars = ['LANG', 'LC_ALL', 'TZ']
    for var in required_vars:
        value = os.environ.get(var)
        if value:
            print(f"  PASS: {var}={value}")
        else:
            print(f"  FAIL: {var} not set")
            return False
    
    return True

def test_packages():
    """Test that required packages are installed"""
    print("\nTesting installed packages...")
    
    # Test that Python3 is available
    try:
        result = subprocess.run(['python3', '--version'], 
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                              universal_newlines=True, timeout=5)
        if result.returncode == 0:
            print(f"  PASS: Python: {result.stdout.strip()}")
        else:
            print("  FAIL: Python3 not working")
            return False
    except Exception as e:
        print(f"  FAIL: Python3 test failed: {e}")
        return False
    
    # Test jq is available
    try:
        result = subprocess.run(['jq', '--version'], 
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                              universal_newlines=True, timeout=5)
        if result.returncode == 0:
            print(f"  PASS: jq: {result.stdout.strip()}")
        else:
            print("  FAIL: jq not available")
    except Exception as e:
        print(f"  WARNING: jq test failed: {e}")
    
    return True

def test_file_permissions():
    """Test critical file permissions"""
    print("\nTesting file permissions...")
    
    # Check /etc/passwd permissions
    try:
        stat_info = os.stat('/etc/passwd')
        mode = oct(stat_info.st_mode)[-3:]
        if mode == '644':
            print("  PASS: /etc/passwd has correct permissions (644)")
        else:
            print(f"  WARNING: /etc/passwd has mode {mode}, expected 644")
    except Exception as e:
        print(f"  FAIL: Could not check /etc/passwd: {e}")
        return False
    
    # Check home directory
    try:
        home_dir = '/app'
        stat_info = os.stat(home_dir)
        print(f"  PASS: {home_dir} exists and is accessible")
    except Exception as e:
        print(f"  FAIL: Home directory issue: {e}")
        return False
    
    return True

def main():
    """Run all tests"""
    print("RHEL 8 Hardened Base Image Tests")
    print("=" * 33)
    
    tests = [
        test_user_security,
        test_environment,
        test_packages,
        test_file_permissions
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            print(f"  FAIL: Test failed with exception: {e}")
    
    print(f"\nTest Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("All tests passed! Base image is working correctly.")
        sys.exit(0)
    else:
        print("Some tests failed. Check the hardened base image configuration.")
        sys.exit(1)

if __name__ == "__main__":
    main()