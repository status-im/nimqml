proc openUrl*(url: string): bool 
    ## Open the given URL in the default browser
    result = dos_qdesktopservices_open_url(url.cstring)