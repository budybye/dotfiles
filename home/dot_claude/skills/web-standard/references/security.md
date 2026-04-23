# Web Security Reference

## Core Security Principles

### Defense in Depth
- Multiple layers of security controls
- Redundancy in protection mechanisms
- Fail-safe defaults

### Principle of Least Privilege
- Minimal necessary permissions
- Role-based access control
- Just-in-time access provisioning

### Secure by Default
- Security enabled out-of-the-box
- Explicit opt-out for less secure options
- Strong default configurations

## Common Web Vulnerabilities

### Injection Attacks
- **SQL Injection** - Malicious SQL code in queries
- **Cross-Site Scripting (XSS)** - Malicious scripts in web pages
- **Command Injection** - OS commands executed on server

### Broken Authentication
- Weak password policies
- Session fixation
- Credential stuffing
- Brute force attacks

### Sensitive Data Exposure
- Unencrypted data transmission
- Insecure storage of sensitive data
- Weak cryptographic algorithms
- Information leakage

### Cross-Site Request Forgery (CSRF)
- Unauthorized commands from trusted users
- Lack of anti-CSRF tokens
- Same-site cookie attributes

### Security Misconfiguration
- Default configurations
- Exposed error messages
- Unprotected files and directories
- Missing security headers

## Security Headers

### Essential Headers
```http
Content-Security-Policy: default-src 'self';
Strict-Transport-Security: max-age=31536000; includeSubDomains;
X-Content-Type-Options: nosniff;
X-Frame-Options: DENY;
X-XSS-Protection: 1; mode=block;
Referrer-Policy: strict-origin-when-cross-origin;
Permissions-Policy: geolocation=(), microphone=(), camera=();
```

### Content Security Policy (CSP)
```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline';
               style-src 'self' 'unsafe-inline';">
```

## Input Validation and Sanitization

### Server-Side Validation
- Whitelist allowed characters
- Validate data types and ranges
- Reject unexpected input
- Sanitize output for context

### Client-Side Validation
- Enhance user experience
- Never trust as security boundary
- Always validate server-side

### Encoding Contexts
- HTML encoding for page content
- JavaScript encoding for dynamic code
- URL encoding for query parameters
- CSS encoding for style values

## Authentication Security

### Password Security
- Strong password policies
- Secure password storage (bcrypt, scrypt, Argon2)
- Multi-factor authentication (MFA)
- Account lockout mechanisms

### Session Management
- Secure session tokens
- Regenerate session IDs after login
- Set secure and HttpOnly flags
- Implement idle and absolute timeouts

### Token-Based Authentication
- JWT best practices
- Short-lived access tokens
- Secure refresh token storage
- Token revocation mechanisms

## Secure Communication

### HTTPS Implementation
- TLS 1.2+ only
- Strong cipher suites
- HSTS header implementation
- Certificate pinning (HPKP or CT)

### Mixed Content Prevention
- Eliminate HTTP resources on HTTPS pages
- Upgrade insecure requests
- Content Security Policy directives

## Client-Side Security

### Cross-Origin Resource Sharing (CORS)
- Restrict origins explicitly
- Validate credentials carefully
- Limit exposed headers

### iframe Security
- X-Frame-Options header
- Content-Security-Policy frame-ancestors
- frameguard middleware

### Subresource Integrity
```html
<script src="https://cdn.example.com/lib.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>
```

## Privacy Considerations

### Data Protection
- GDPR, CCPA compliance
- Data minimization
- Purpose limitation
- User consent mechanisms

### Tracking Prevention
- Third-party cookie blocking
- Fingerprinting resistance
- Analytics without identification

## Security Testing

### Automated Scanning
- Static Application Security Testing (SAST)
- Dynamic Application Security Testing (DAST)
- Software Composition Analysis (SCA)

### Manual Testing
- Penetration testing
- Security code reviews
- Threat modeling

### Security Headers Testing
- SecurityHeaders.io
- Mozilla Observatory
- CSP Evaluator