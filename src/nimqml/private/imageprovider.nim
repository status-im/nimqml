proc setup*(self: QIPFSAsyncImageProvider, ipfsTmpDir, gateway: string) =
  self.vptr = dos_ipfsasyncimageprovider_create(ipfsTmpDir.cstring, gateway.cstring)

proc delete*(self: QIPFSAsyncImageProvider) =
  if self.vptr.isNil:
    return
  self.vptr.resetToNil

proc newQIPFSAsyncImageProvider*(ipfsTmpDir, gateway: string): QIPFSAsyncImageProvider =
  new(result, delete)
  result.setup(ipfsTmpDir, gateway)
