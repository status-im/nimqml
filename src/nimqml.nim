## NimQml aims to provide binding to the QML for the Nim programming language

template debugMsg(message: string) =
  echo "NimQml: ", message

template debugMsg(typeName: string, procName: string) =
  when defined(debugNimQml):
    var message = typeName
    message &= ": "
    message &= procName
    debugMsg(message)

import os

include "nimqml/private/dotherside.nim"
include "nimqml/private/nimqmltypes.nim"
include "nimqml/private/qmetaobject.nim"
include "nimqml/private/qnetworkconfigurationmanager.nim"
include "nimqml/private/qvariant.nim"
include "nimqml/private/qobject.nim"
include "nimqml/private/qqmlapplicationengine.nim"
include "nimqml/private/qguiapplication.nim"
include "nimqml/private/qurl.nim"
include "nimqml/private/qquickview.nim"
include "nimqml/private/qhashintbytearray.nim"
include "nimqml/private/qmodelindex.nim"
include "nimqml/private/qabstractitemmodel.nim"
include "nimqml/private/qabstractlistmodel.nim"
include "nimqml/private/qabstracttablemodel.nim"
include "nimqml/private/qresource.nim"
include "nimqml/private/qdeclarative.nim"
include "nimqml/private/qsettings.nim"
include "nimqml/private/qtimer.nim"
include "nimqml/private/nimqmlmacros.nim"
include "nimqml/private/singleinstance.nim"
include "nimqml/private/status/statusevent.nim"
include "nimqml/private/status/statusosnotification.nim"
include "nimqml/private/status/statuskeychainmanager.nim"

proc signal_handler*(receiver: pointer, signal: cstring, slot: cstring) =
  var dosqobj = cast[DosQObject](receiver)
  if(dosqobj.isNil == false):
    dos_signal(receiver, signal, slot)

proc image_resizer*(imagePath: string, maxSize: int = 2000, tmpDir: string): string =
  discard existsOrCreateDir(tmpDir)
  let imgResizer = dos_image_resizer(imagePath.cstring, maxSize.cint, tmpDir.cstring)
  defer: dos_chararray_delete(imgResizer)
  result = $(imgResizer)

proc plain_text*(htmlString: string): string =
  let plainText = dos_plain_text(htmlString.cstring)
  defer: dos_chararray_delete(plainText)
  result = $(plainText)

proc escape_html*(input: string): string =
  let escapedHtml = dos_escape_html(input.cstring)
  defer: dos_chararray_delete(escapedHtml)
  result = $(escapedHtml)

proc url_fromUserInput*(input: string): string =
  let urlStr = dos_qurl_fromUserInput(input.cstring)
  defer: dos_chararray_delete(urlStr)
  result = $(urlStr)

proc url_host*(host: string): string =
  let qurlHost = dos_qurl_host(host.cstring)
  defer: dos_chararray_delete(qurlHost)
  result = $(qurlHost)

proc url_replaceHostAndAddPath*(url: string, newHost: string, protocol: string = "", pathPrefix: string = ""): string =
  let newUrl = dos_qurl_replaceHostAndAddPath(url.cstring, protocol.cstring, newHost.cstring, pathPrefix.cstring)
  defer: dos_chararray_delete(newUrl)
  result = $(newUrl)

proc url_toLocalFile*(fileUrl: string): string =
  let filePath = dos_to_local_file(fileUrl.cstring)
  defer: dos_chararray_delete(filePath)
  result = $(filePath)

proc url_fromLocalFile*(filePath: string): string =
  let url = dos_from_local_file(filePath.cstring)
  defer: dos_chararray_delete(url)
  result = $(url)

proc app_isActive*(engine: QQmlApplicationEngine): bool =
  result = dos_app_is_active(engine.vptr)
proc app_makeItActive*(engine: QQmlApplicationEngine) =
  dos_app_make_it_active(engine.vptr)
