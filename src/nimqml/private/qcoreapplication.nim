proc enableHDPI*() =
  dos_qapplication_enable_hdpi()

proc initializeOpenGL*() =
  dos_qapplication_initialize_opengl()
  
proc applicationDirPath*(app: QCoreApplication): string =
  let str = dos_qcoreapplication_application_dir_path()
  result = $str
  dos_chararray_delete(str)

proc processEvents*(flags: QEventLoopFlag) =
  dos_qcoreapplication_process_events(cint(ord(flags)))

proc processEvents*(flags: QEventLoopFlag, timeOut: int) =
  dos_qcoreapplication_process_events_timed(cint(ord(flags)), timeOut)