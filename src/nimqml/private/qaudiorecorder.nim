proc setup*(self: QAudioRecorder, tmpPath: string) =
  self.vptr = dos_qaudiorecorder_create(tmpPath.cstring)

proc delete*(self: QAudioRecorder) =
  if self.vptr.isNil:
    return
  dos_qaudiorecorder_delete(self.vptr)
  self.vptr.resetToNil

proc newQAudioRecorder*(tmpPath: string): QAudioRecorder =
  new(result, delete)
  result.setup(tmpPath)

proc start*(self: QAudioRecorder) =
  dos_qaudiorecorder_start(self.vptr)

proc stop*(self: QAudioRecorder): string =
  result = $dos_qaudiorecorder_stop(self.vptr)
