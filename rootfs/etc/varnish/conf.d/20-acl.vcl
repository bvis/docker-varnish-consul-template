# ACL

acl purge {
  # ACL we'll use later to allow purges
  "localhost";
  "127.0.0.1";
  "::1";
}

/*
acl editors {
  # ACL to honor the "Cache-Control: no-cache" header to force a refresh but only from selected IPs
  "localhost";
  "127.0.0.1";
  "::1";
}
*/
