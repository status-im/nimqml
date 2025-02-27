proc openUrl*(url: string = ""): bool =
  ## Open the given URL in the appropriate browser
  return dos_qdesktopservices_open_url(url.cstring)
