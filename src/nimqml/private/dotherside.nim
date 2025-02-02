import strutils
import tables
const dynLibName =
  case system.hostOS:
    of "windows":
      "DOtherSide.dll"
    of "macosx":
      "libDOtherSide.dylib"
    else:
      "libDOtherSide.so.0.6"

{.push raises: [].}

type
  NimQObject = pointer
  NimQAbstractItemModel = pointer
  NimQAbstractListModel = pointer
  NimQAbstractTableModel = pointer
  DosQMetaObject = distinct pointer
  DosQObject = distinct pointer
  DosQQNetworkAccessManagerFactory = pointer
  DosQQNetworkAccessManager = distinct DosQObject
  DosQObjectWrapper = distinct pointer
  DosQVariant = distinct pointer
  DosQQmlContext = distinct pointer
  DosQQmlApplicationEngine = distinct pointer
  DosQVariantArray = UncheckedArray[DosQVariant]
  DosQMetaType = cint
  DosQMetaTypeArray = UncheckedArray[DosQMetaType]
  DosQUrl = distinct pointer
  DosQQuickView = distinct pointer
  DosQHashIntByteArray = distinct pointer
  DosQModelIndex = distinct pointer
  DosQAbstractItemModel = distinct pointer
  DosQAbstractTableModel = distinct pointer
  DosQAbstractListModel = distinct pointer
  DosQMetaObjectConnection = distinct pointer
  DosStatusEvent = DosQObject
  DosStatusOSNotification = DosQObject
  DosQSettings = DosQObject
  DosStatusKeychainManager = DosQObject
  DosQTimer = DosQObject
  
  DosParameterDefinition = object
    name: cstring
    metaType: cint

  DosSignalDefinition = object
    name: cstring
    parametersCount: cint
    parameters: pointer

  DosSignalDefinitions = object
    count: cint
    definitions: pointer

  DosSlotDefinition = object
    name: cstring
    returnMetaType: cint
    parametersCount: cint
    parameters: pointer

  DosSlotDefinitions = object
    count: cint
    definitions: pointer

  DosPropertyDefinition = object
    name: cstring
    propertyMetaType: cint
    readSlot: cstring
    writeSlot: cstring
    notifySignal: cstring

  DosPropertyDefinitions = object
    count: cint
    definitions: pointer

  DosCreateCallback = proc(id: cint, wrapper: DosQObjectWrapper, nimQObject: var NimQObject, dosQObject: var DosQObject) {.cdecl.}
  DosDeleteCallback = proc(id: cint, nimQObject: NimQObject) {.cdecl.}

  DosQmlRegisterType = object
    major: cint
    minor: cint
    uri: cstring
    qml: cstring
    staticMetaObject: DosQMetaObject
    createCallback: DosCreateCallback
    deleteCallback: DosDeleteCallback

  DosQObjectCallBack = proc(nimobject: NimQObject, slotName: DosQVariant, numArguments: cint, arguments: ptr DosQVariantArray) {.cdecl.}

  DosRowCountCallback = proc(nimmodel: NimQAbstractItemModel, rawIndex: DosQModelIndex, result: var cint) {.cdecl.}
  DosColumnCountCallback = proc(nimmodel: NimQAbstractItemModel, rawIndex: DosQModelIndex, result: var cint) {.cdecl.}
  DosDataCallback = proc(nimmodel: NimQAbstractItemModel, rawIndex: DosQModelIndex, role: cint, result: DosQVariant) {.cdecl.}
  DosSetDataCallback = proc(nimmodel: NimQAbstractItemModel, rawIndex: DosQModelIndex, value: DosQVariant, role: cint, result: var bool) {.cdecl.}
  DosRoleNamesCallback = proc(nimmodel: NimQAbstractItemModel): Table[cint, seq[byte]] {.cdecl.}
  DosFlagsCallback = proc(nimmodel: NimQAbstractItemModel, index: DosQModelIndex, result: var cint) {.cdecl.}
  DosHeaderDataCallback = proc(nimmodel: NimQAbstractItemModel, section: cint, orientation: cint, role: cint, result: DosQVariant) {.cdecl.}
  DosIndexCallback = proc(nimmodel: NimQAbstractItemModel, row: cint, column: cint, parent: DosQModelIndex, result: var DosQModelIndex) {.cdecl.}
  DosParentCallback = proc(nimmodel: NimQAbstractItemModel, child: DosQModelIndex, result: var DosQModelIndex) {.cdecl.}
  DosHasChildrenCallback = proc(nimmodel: NimQAbstractItemModel, parent: DosQModelIndex, result: var bool) {.cdecl.}
  DosCanFetchMoreCallback = proc(nimmodel: NimQAbstractItemModel, parent: DosQModelIndex, result: var bool) {.cdecl.}
  DosFetchMoreCallback = proc(nimmodel: NimQAbstractItemModel, parent: DosQModelIndex) {.cdecl.}

  DosQAbstractItemModelCallbacks = object
    rowCount: DosRowCountCallback
    columnCount: DosColumnCountCallback
    data: DosDataCallback
    setData: DosSetDataCallback
    roleNames: DosRoleNamesCallback
    flags: DosFlagsCallback
    headerData: DosHeaderDataCallback
    index: DosIndexCallback
    parent: DosParentCallback
    hasChildren: DosHasChildrenCallback
    canFetchMore: DosCanFetchMoreCallback
    fetchMore: DosFetchMoreCallback

  DosQObjectConnectLambdaCallback = proc(data: pointer, numArguments: cint, arguments: ptr DosQVariantArray) {.cdecl.}
  DosQMetaObjectInvokeMethodCallback = proc(data: pointer) {.cdecl.}

  DosMessageHandler = proc(messageType: cint, message: cstring, category: cstring, file: cstring, function: cstring, lint: cint) {.cdecl.}


include notherside

# Status extensions to notherside
import
  gen_qnamespace,
  network/gen_qnetworkaccessmanager,
  quick/gen_qqmlnetworkaccessmanagerfactory

converter toQNetworkAccessManager*(v: gen_qnetworkaccessmanager_types.QNetworkAccessManager): DosQQNetworkAccessManager =
  DosQQNetworkAccessManager(v.h)

converter toQNetworkAccessManager*(v: DosQQNetworkAccessManager): gen_qnetworkaccessmanager_types.QNetworkAccessManager =
  gen_qnetworkaccessmanager_types.QNetworkAccessManager(h: pointer(v))

converter toQQmlNetworkAccessManagerFactory*(v: gen_qqmlnetworkaccessmanagerfactory_types.QQmlNetworkAccessManagerFactory): DosQQNetworkAccessManagerFactory =
  DosQQNetworkAccessManagerFactory(v.h)

converter toQQmlNetworkAccessManagerFactory*(v: DosQQNetworkAccessManagerFactory): gen_qqmlnetworkaccessmanagerfactory_types.QQmlNetworkAccessManagerFactory =
  gen_qqmlnetworkaccessmanagerfactory_types.QQmlNetworkAccessManagerFactory(h: pointer(v))

# Conversion
proc resetToNil[T](x: var T) = reset(x)
proc isNil(x: DosQMetaObject): bool = x.pointer.isNil
proc isNil(x: DosQVariant): bool = x.pointer.isNil
proc isNil(x: DosQObject): bool = x.pointer.isNil
proc isNil(x: DosQQmlApplicationEngine): bool = x.pointer.isNil
proc isNil(x: DosQUrl): bool = x.pointer.isNil
proc isNil(x: DosQQuickView): bool = x.pointer.isNil
proc isNil(x: DosQHashIntByteArray): bool = x.pointer.isNil
proc isNil(x: DosQModelIndex): bool = x.pointer.isNil

# CharArray
from system/ansi_c import c_malloc
proc newcstring(s: string): cstring =
  # TODO new[] vs malloc
  let tmp = cast[ptr UncheckedArray[char]](c_malloc(csize_t(s.len + 1)))
  tmp[s.len] = default(char)
  if s.len > 0:
    copyMem(addr tmp[0], addr s[0], csize_t(s.len))
  cast[cstring](addr tmp[0])

proc dos_chararray_delete(str: cstring) =
  debugEcho "dos_chararray_delete(str: cstring) "

# QGuiApplication
proc dos_qguiapplication_application_dir_path(): cstring =
  newcstring(gen_qguiapplication.QGuiApplication.applicationDirPath())

proc dos_qguiapplication_enable_hdpi(uiScaleFilePath: cstring) =
  gen_qguiapplication.QGuiApplication.setAttribute(ApplicationAttributeEnum.AA_EnableHighDpiScaling)
  gen_qguiapplication.QGuiApplication.setHighDpiScaleFactorRoundingPolicy(HighDpiScaleFactorRoundingPolicyEnum.PassThrough)

proc dos_qguiapplication_initialize_opengl() =
  gen_qguiapplication.QGuiApplication.setAttribute(ApplicationAttributeEnum.AA_ShareOpenGLContexts);

proc dos_qtwebview_initialize() {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_try_enable_threaded_renderer() {.cdecl, dynlib: dynLibName, importc.}

# TODO expose static qt instance instead ..
var gApp {.threadvar.}: gen_qguiapplication.QGuiApplication

proc dos_qguiapplication_create() =
  noExceptions:
    os.putenv("QV4_JS_MAX_STACK_SIZE", "10485760");
    os.putenv("QT_QUICK_CONTROLS_HOVER_ENABLED", "1");

  gApp = gen_qguiapplication.QGuiApplication.create();

  # TODO register_meta_types();

proc dos_qguiapplication_exec() = discard gen_qguiapplication.QGuiApplication.exec()
proc dos_qguiapplication_quit() = gen_qguiapplication.QGuiApplication.quit()

proc dos_qguiapplication_restart() {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_icon(filename: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_delete() {.cdecl, dynlib: dynLibName, importc.}

proc dos_qguiapplication_clipboard_setText(content: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_clipboard_getText(): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_installEventFilter(engine: DosStatusEvent) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_clipboard_setImage(content: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_download_image(imageSource: cstring, filePath: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_clipboard_setImageByUrl(url: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_download_imageByUrl(url: cstring, filePath: cstring) {.cdecl, dynlib: dynLibName, importc.}

proc dos_add_self_signed_certificate(content: cstring) {.cdecl, dynlib: dynLibName, importc.}

# QQmlContext
proc dos_qqmlcontext_setcontextproperty(context: DosQQmlContext, propertyName: cstring, propertyValue: DosQVariant) {.cdecl, dynlib: dynLibName, importc.}

# QQmlApplicationEngine
proc dos_qqmlapplicationengine_create(): DosQQmlApplicationEngine = gen_qqmlapplicationEngine.QQmlApplicationEngine.create()
proc dos_qqmlapplicationengine_getNetworkAccessManager(engine: DosQQmlApplicationEngine): DosQQNetworkAccessManager = engine.networkAccessManager()
proc dos_qqmlapplicationengine_setNetworkAccessManagerFactory(engine: DosQQmlApplicationEngine, factory: DosQQNetworkAccessManagerFactory) = engine.setNetworkAccessManagerFactory(factory)
proc dos_qqmlapplicationengine_load(engine: DosQQmlApplicationEngine, filename: cstring) = engine.load($filename)
proc dos_qqmlapplicationengine_load_url(engine: DosQQmlApplicationEngine, url: DosQUrl) = engine.load(url)
proc dos_qqmlapplicationengine_load_data(engine: DosQQmlApplicationEngine, data: cstring) = engine.loadData(cast[seq[byte]]($data))
proc dos_qqmlapplicationengine_add_import_path(engine: DosQQmlApplicationEngine, path: cstring) = engine.addImportPath($path)
proc dos_qqmlapplicationengine_context(engine: DosQQmlApplicationEngine): DosQQmlContext = engine.rootContext()
proc dos_qqmlapplicationengine_delete(engine: DosQQmlApplicationEngine) = gen_qqmlapplicationengine.QQmlApplicationEngine(engine).delete()
proc dos_qguiapplication_load_translation(engine: DosQQmlApplicationEngine, content: cstring, shouldRetranslate: bool) {.cdecl, dynlib: dynLibName, importc.}

# QVariant
proc dos_qvariant_create(): DosQVariant =
  gen_qvariant.QVariant.create()

proc dos_qvariant_create_int(value: cint): DosQVariant =
  gen_qvariant.QVariant.create(value)

proc dos_qvariant_create_int(value: clonglong): DosQVariant =
  gen_qvariant.QVariant.create(value)
proc dos_qvariant_create_uint(value: cuint): DosQVariant =
  gen_qvariant.QVariant.create(value)
proc dos_qvariant_create_longlong(value: clonglong): DosQVariant =
  gen_qvariant.QVariant.create(value)
proc dos_qvariant_create_ulonglong(value: culonglong): DosQVariant =
  gen_qvariant.QVariant.create(value)

proc dos_qvariant_create_bool(value: bool): DosQVariant =
  gen_qvariant.QVariant.create(value)

proc dos_qvariant_create_string(value: cstring): DosQVariant =
  gen_qvariant.QVariant.create(value)

proc dos_qvariant_create_qobject(value: DosQObject): DosQVariant =
  gen_qvariant.QVariant.fromValue(value)

proc dos_qvariant_create_qvariant(value: DosQVariant): DosQVariant =
  gen_qvariant.QVariant.create(value)

proc dos_qvariant_create_float(value: cfloat): DosQVariant =
  gen_qvariant.QVariant.create(value)

proc dos_qvariant_create_double(value: cdouble): DosQVariant =
  gen_qvariant.QVariant.create(value)

proc dos_qvariant_delete(variant: DosQVariant) =
  variant.delete()

proc dos_qvariant_isnull(variant: DosQVariant): bool =
  variant.isNull()

proc dos_qvariant_toInt(variant: DosQVariant): cint =
  variant.toInt()
proc dos_qvariant_toUInt(variant: DosQVariant): cuint =
  variant.toUInt()
proc dos_qvariant_toLongLong(variant: DosQVariant): clonglong =
  variant.toLongLong()
proc dos_qvariant_toULongLong(variant: DosQVariant): culonglong =
  variant.toULongLong()

proc dos_qvariant_toBool(variant: DosQVariant): bool =
  variant.toBool()

proc dos_qvariant_toString(variant: DosQVariant): string =
  variant.toString()

proc dos_qvariant_toDouble(variant: DosQVariant): cdouble =
  variant.toDouble()

proc dos_qvariant_toFloat(variant: DosQVariant): cfloat =
  variant.toFloat()

proc dos_qvariant_setInt(variant: DosQVariant, value: cint) =
  variant.operatorAssign(gen_qvariant.QVariant.create(value))
proc dos_qvariant_setUInt(variant: DosQVariant, value: cuint) =
  variant.operatorAssign(gen_qvariant.QVariant.create(value))
proc dos_qvariant_setLongLong(variant: DosQVariant, value: clonglong) =
  variant.operatorAssign(gen_qvariant.QVariant.create(value))
proc dos_qvariant_setULongLong(variant: DosQVariant, value: culonglong) =
  variant.operatorAssign(gen_qvariant.QVariant.create(value))

proc dos_qvariant_setBool(variant: DosQVariant, value: bool) =
  variant.operatorAssign(gen_qvariant.QVariant.create(value))

proc dos_qvariant_setString(variant: DosQVariant, value: cstring) =
  variant.operatorAssign(gen_qvariant.QVariant.create(value))

proc dos_qvariant_assign(leftValue: DosQVariant, rightValue: DosQVariant) =
  leftValue.operatorAssign(rightValue)

proc dos_qvariant_setFloat(variant: DosQVariant, value: cfloat) =
  variant.operatorAssign(dos_qvariant_create_float(value))

proc dos_qvariant_setDouble(variant: DosQVariant, value: cdouble) =
  variant.operatorAssign(dos_qvariant_create_double(value))

proc dos_qvariant_setQObject(variant: DosQVariant, value: DosQObject) =
  variant.operatorAssign(dos_qvariant_create_qobject(value))

# QMetaObject
proc dos_qmetaobject_create(superclassMetaObject: DosQMetaObject,
                            className: cstring,
                            signalDefinitions: ptr DosSignalDefinitions,
                            slotDefinitions: ptr DosSlotDefinitions,
                            propertyDefinitions: ptr DosPropertyDefinitions): DosQMetaObject =
  nos_qmetaobject_create(superclassMetaObject, className, signalDefinitions, slotDefinitions, propertyDefinitions)
proc dos_qmetaobject_delete(vptr: DosQMetaObject) =
  vptr.delete()

# QObject
proc dos_qobject_qmetaobject(): DosQMetaObject =
  var signalDefs: DosSignalDefinitions
  var slotDefs: DosSlotDefinitions
  var propDefs: DosPropertyDefinitions

  dos_qmetaobject_create(
    gen_qobject.QObject.staticMetaObject(),
    "DosQObject",
    addr signalDefs,
    addr slotDefs,
    addr propDefs,
  )
proc dos_qobject_create(nimobject: NimQObject, metaObject: DosQMetaObject, dosQObjectCallback: DosQObjectCallBack): DosQObject =
  let vtbl = new QObjectVtable
  gen_qobject.QObject.setupCallbacks(
    nimobject, metaObject, dosQObjectCallback, vtbl[], QObjectmetacall
  )

  gen_qobject.QObject.create(vtbl = vtbl)

proc dos_qobject_objectName(qobject: DosQObject): cstring =
  debugEcho "dos_qobject_objectName(qobject: DosQObject): cstring "

proc dos_qobject_setObjectName(qobject: DosQObject, name: cstring) =
  qobject.setObjectName($name)
proc dos_qobject_signal_emit(qobject: DosQObject, signalName: cstring, argumentsCount: cint, arguments: ptr DosQVariantArray) =
  let mo = qobject.metaObject()

  for i in 0 ..< mo.methodCount:
    let meth = mo.methodX(cint(i))
    if meth.parameterCount() == argumentsCount and signalName.toOpenArrayByte(0, len(signalName) - 1) == meth.name:

      var argv = newSeq[pointer](argumentsCount + 1)
      for i in 0 ..< argumentsCount:
        argv[i + 1] = arguments[i].constData()
      gen_qobjectdefs.QMetaObject.activate(qobject, cint i, addr argv[0])
      break

proc dos_qobject_connect_static(
    sender: DosQObject,
    senderFunc: cstring,
    receiver: DosQObject,
    receiverFunc: cstring,
    connectionType: cint,
): DosQMetaObjectConnection =
  receiver.connect(sender, senderFunc, receiverFunc)

proc dos_qobject_connect_lambda_static(
    sender: DosQObject,
    senderFunc: cstring,
    callback: DosQObjectConnectLambdaCallback,
    data: pointer,
    connectionType: cint,
): DosQMetaObjectConnection =
  nos_qobject_connect_lambda_with_context_static(sender, senderFunc, sender, callback, data, connectionType)
proc dos_qobject_connect_lambda_with_context_static(
    sender: DosQObject,
    senderFunc: cstring,
    context: DosQObject,
    callback: DosQObjectConnectLambdaCallback,
    data: pointer,
    connectionType: cint,
): DosQMetaObjectConnection =
  nos_qobject_connect_lambda_with_context_static(sender, senderFunc, context, callback, data, connectionType)

proc dos_qobject_disconnect_static(
    sender: DosQObject, senderFunc: cstring, receiver: DosQObject, receiverFunc: cstring
) =
  debugEcho "dos_qobject_disconnect_static"

proc dos_qobject_disconnect_with_connection_static(connection: DosQMetaObjectConnection) =
  discard QObject.disconnect(connection)

proc dos_qobject_delete(qobject: DosQObject) =
  qobject.delete()

proc dos_qobject_deleteLater(qobject: DosQObject) =
  qobject.deleteLater()

proc dos_qobject_signal_connect(sender: DosQObject, signalName: cstring, receiver: DosQObject, slot: cstring, signalType: cint) {.cdecl, dynlib: dynLibName, importc.}

# QAbstractItemModel
proc dos_qabstractitemmodel_qmetaobject(): DosQMetaObject =
  var signalDefs: DosSignalDefinitions
  var slotDefs: DosSlotDefinitions
  var propDefs: DosPropertyDefinitions

  dos_qmetaobject_create(
    gen_qabstractitemmodel.QAbstractItemModel.staticMetaObject(),
    "DosQAbstractItemModel",
    addr signalDefs,
    addr slotDefs,
    addr propDefs,
  )

# status-go signal handler
proc dos_signal(vptr: pointer, signal: cstring, slot: cstring) {.cdecl, dynlib: dynLibName, importc.}

# QUrl
proc dos_qurl_create(url: cstring, parsingMode: cint): DosQUrl =
  QUrl.create($url, parsingMode)

proc dos_qurl_delete(vptr: DosQUrl) =
  vptr.delete()

proc dos_qurl_to_string(vptr: DosQUrl): string =
  vptr.toString()

# QNetworkConfigurationManager
proc dos_qncm_create(): DosQObject {.cdecl, dynlib: dynLibName, importc.}
proc dos_qncm_delete(vptr: DosQObject) {.cdecl, dynlib: dynLibName, importc.}

# QNetworkAccessManagerFactory
proc dos_qqmlnetworkaccessmanagerfactory_create(tmpPath: cstring): DosQQNetworkAccessManagerFactory {.cdecl, dynlib: dynLibName, importc.}

# QNetworkAccessManager
proc dos_qqmlnetworkaccessmanager_clearconnectioncache(vptr: DosQQNetworkAccessManager) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlnetworkaccessmanager_setnetworkaccessible(vptr: DosQQNetworkAccessManager, accessible: cint) {.cdecl, dynlib: dynLibName, importc.}

# QQuickView
proc dos_qquickview_create(): DosQQuickView =
  debugEcho "dos_qquickview_create(): DosQQuickView "

proc dos_qquickview_delete(view: DosQQuickView) =
  debugEcho "dos_qquickview_delete(view: DosQQuickView) "

proc dos_qquickview_show(view: DosQQuickView) =
  debugEcho "dos_qquickview_show(view: DosQQuickView) "

proc dos_qquickview_source(view: DosQQuickView): cstring =
  debugEcho "dos_qquickview_source(view: DosQQuickView): cstring "

proc dos_qquickview_set_source(view: DosQQuickView, filename: cstring) =
  debugEcho "dos_qquickview_set_source(view: DosQQuickView, filename: cstring) "

# QHash<int, QByteArra>
proc dos_qhash_int_qbytearray_create(): DosQHashIntByteArray =
  debugEcho "dos_qhash_int_qbytearray_create(): DosQHashIntByteArray "

proc dos_qhash_int_qbytearray_delete(qHash: DosQHashIntByteArray) =
  debugEcho "dos_qhash_int_qbytearray_delete(qHash: DosQHashIntByteArray) "

proc dos_qhash_int_qbytearray_insert(
    qHash: DosQHashIntByteArray, key: int, value: cstring
) =
  debugEcho "dos_qhash_int_qbytearray_insert(qHash: DosQHashIntByteArray, key: int, value: cstring) "

proc dos_qhash_int_qbytearray_value(qHash: DosQHashIntByteArray, key: int): cstring =
  debugEcho "dos_qhash_int_qbytearray_value(qHash: DosQHashIntByteArray, key: int): cstring "

# QModelIndex
proc dos_qmodelindex_create(): DosQModelIndex =
  gen_qabstractitemdelegate.QModelIndex.create()

proc dos_qmodelindex_create_qmodelindex(other: DosQModelIndex): DosQModelIndex =
  gen_qabstractitemdelegate.QModelIndex.create(other)

proc dos_qmodelindex_delete(modelIndex: DosQModelIndex) =
  modelIndex.delete()

proc dos_qmodelindex_row(modelIndex: DosQModelIndex): cint =
  modelIndex.row()

proc dos_qmodelindex_column(modelIndex: DosQModelIndex): cint =
  modelIndex.column()

proc dos_qmodelindex_isValid(modelIndex: DosQModelIndex): bool =
  modelIndex.isValid()

proc dos_qmodelindex_data(modelIndex: DosQModelIndex, role: cint): DosQVariant =
  modelIndex.data(role)

proc dos_qmodelindex_parent(modelIndex: DosQModelIndex): DosQModelIndex =
  modelIndex.parent()

proc dos_qmodelindex_child(
    modelIndex: DosQModelIndex, row: cint, column: cint
): DosQModelIndex =
  modelIndex.child(row, column)

proc dos_qmodelindex_sibling(
    modelIndex: DosQModelIndex, row: cint, column: cint
): DosQModelIndex =
  modelIndex.sibling(row, column)

proc dos_qmodelindex_assign(leftSide: var DosQModelIndex, rightSide: DosQModelIndex) =
  if not isNil(pointer(leftSide)): leftSide.delete()
  leftSide = gen_qabstractitemmodel.QModelIndex.create(rightSide)

proc dos_qmodelindex_internalPointer(modelIndex: DosQModelIndex): pointer =
  modelIndex.internalPointer()

# QAbstractItemModel
proc dos_qabstractitemmodel_create(modelPtr: NimQAbstractItemModel,
                                   metaObject: DosQMetaObject,
                                   qobjectCallback: DosQObjectCallBack,
                                   qaimCallbacks: DosQAbstractItemModelCallbacks): DosQAbstractItemModel =
  let vtbl = new QAbstractItemModelVTable
  gen_qabstractitemmodel.QAbstractItemModel.setupCallbacks(
    modelPtr, metaObject, qobjectCallback, vtbl[], QAbstractItemModelmetacall
  )
  gen_qabstractitemmodel.QAbstractItemModel.setupCallbacks(
    modelPtr, qaimCallbacks, vtbl[]
  )

  gen_qabstractitemmodel.QAbstractItemModel.create(vtbl)

proc dos_qabstractitemmodel_beginInsertRows(model: DosQAbstractItemModel,
                                            parentIndex: DosQModelIndex,
                                            first: cint,
                                            last: cint) =
  model.beginInsertRows(parentIndex, first, last)

proc dos_qabstractitemmodel_endInsertRows(model: DosQAbstractItemModel) =
  model.endInsertRows()

proc dos_qabstractitemmodel_beginRemoveRows(model: DosQAbstractItemModel,
                                            parentIndex: DosQModelIndex,
                                            first: cint,
                                            last: cint) =
  model.beginRemoveRows(parentIndex,first, last)

proc dos_qabstractitemmodel_endRemoveRows(model: DosQAbstractItemModel) =
  model.endRemoveRows()
proc dos_qabstractitemmodel_beginMoveRows(model: DosQAbstractItemModel,
                                            sourceParentIndex: DosQModelIndex, sourceFirst: cint, sourceLast: cint,
                                            destParentIndex: DosQModelIndex, destinationChild: cint) =
  discard model.beginMoveRows(sourceParentIndex, sourceFirst, sourceLast, destParentIndex, destinationChild)

proc dos_qabstractitemmodel_endMoveRows(model: DosQAbstractItemModel) =
  model.endMoveRows()

proc dos_qabstractitemmodel_beginInsertColumns(model: DosQAbstractItemModel,
                                               parentIndex: DosQModelIndex,
                                               first: cint,
                                               last: cint) =
  model.beginInsertColumns(parentIndex, first, last)

proc dos_qabstractitemmodel_endInsertColumns(model: DosQAbstractItemModel) =
  model.endInsertColumns()

proc dos_qabstractitemmodel_beginRemoveColumns(model: DosQAbstractItemModel,
                                               parentIndex: DosQModelIndex,
                                               first: cint,
                                               last: cint) =
  model.beginRemoveColumns(parentIndex, first, last)

proc dos_qabstractitemmodel_endRemoveColumns(model: DosQAbstractItemModel) =
  model.endRemoveColumns()

proc dos_qabstractitemmodel_beginResetModel(model: DosQAbstractItemModel) =
  model.beginResetModel()

proc dos_qabstractitemmodel_endResetModel(model: DosQAbstractItemModel) =
  model.endResetModel()

proc dos_qabstractitemmodel_dataChanged(model: DosQAbstractItemModel,
                                        parentLeft: DosQModelIndex,
                                        bottomRight: DosQModelIndex,
                                        rolesArrayPtr: ptr cint,
                                        rolesArrayLength: cint) =
  model.dataChanged(parentLeft, bottomRight, @(cast[ptr UncheckedArray[cint]](rolesArrayPtr).toOpenArray(0, rolesArrayLength-1)) )

proc dos_qabstractitemmodel_createIndex(model: DosQAbstractItemModel, row: cint, column: cint, data: pointer): DosQModelIndex =
  model.createIndex(row, column, cast[uint](data))

proc dos_qabstractitemmodel_hasChildren(model: DosQAbstractItemModel, parent: DosQModelIndex): bool =
  model.QAbstractItemModelhasChildren(parent)

proc dos_qabstractitemmodel_hasIndex(model: DosQAbstractItemModel, row: int, column: int, parent: DosQModelIndex): bool =
  model.hasIndex(cint row, cint column, parent)

proc dos_qabstractitemmodel_canFetchMore(model: DosQAbstractItemModel, parent: DosQModelIndex): bool =
  QAbstractItemModelcanFetchMore(model, parent)

proc dos_qabstractitemmodel_fetchMore(model: DosQAbstractItemModel, parent: DosQModelIndex) =
  QAbstractItemModelfetchMore(model, parent)

# QResource
proc dos_qresource_register(filename: cstring) =
  discard QResource.registerResource($filename)

# QDeclarative
proc dos_qdeclarative_qmlregistertype(value: ptr DosQmlRegisterType): cint =
  debugEcho "dos_qdeclarative_qmlregistertype(value: ptr DosQmlRegisterType): cint "

proc dos_qdeclarative_qmlregistersingletontype(value: ptr DosQmlRegisterType): cint =
  debugEcho "dos_qdeclarative_qmlregistersingletontype(value: ptr DosQmlRegisterType): cint "

# QAbstractListModel
proc dos_qabstractlistmodel_qmetaobject(): DosQMetaObject =
  var signalDefs: DosSignalDefinitions
  var slotDefs: DosSlotDefinitions
  var propDefs: DosPropertyDefinitions

  dos_qmetaobject_create(
    gen_qabstractitemmodel.QAbstractListModel.staticMetaObject(),
    "DosQAbstractListModel",
    addr signalDefs,
    addr slotDefs,
    addr propDefs,
  )

proc dos_qabstractlistmodel_create(modelPtr: NimQAbstractListModel,
                                   metaObject: DosQMetaObject,
                                   qobjectCallback: DosQObjectCallBack,
                                   qaimCallbacks: DosQAbstractItemModelCallbacks): DosQAbstractListModel =
  let vtbl = new QAbstractListModelVTable
  gen_qabstractitemmodel.QAbstractListModel.setupCallbacks(
    modelPtr, metaObject, qobjectCallback, vtbl[], QAbstractListModelmetacall
  )
  gen_qabstractitemmodel.QAbstractListModel.setupCallbacks(
    modelPtr, qaimCallbacks, vtbl[]
  )

  gen_qabstractitemmodel.QAbstractListModel.create(vtbl = vtbl)

proc dos_qabstractlistmodel_columnCount(modelPtr: DosQAbstractListModel, index: DosQModelIndex): cint =
  QAbstractListModel(modelPtr).columnCount(index)

proc dos_qabstractlistmodel_parent(modelPtr: DosQAbstractListModel, index: DosQModelIndex): DosQModelIndex =
  QAbstractListModel(modelPtr).parent(index)

proc dos_qabstractlistmodel_index(modelPtr: DosQAbstractListModel, row: cint, column: cint, parent: DosQModelIndex): DosQModelIndex =
  modelPtr.QAbstractListModelindex(row, column, parent)

# QAbstractTableModel
proc dos_qabstracttablemodel_qmetaobject(): DosQMetaObject =
  var signalDefs: DosSignalDefinitions
  var slotDefs: DosSlotDefinitions
  var propDefs: DosPropertyDefinitions

  dos_qmetaobject_create(
    gen_qabstractitemmodel.QAbstractTableModel.staticMetaObject(),
    "DosQAbstractTableModel",
    addr signalDefs,
    addr slotDefs,
    addr propDefs,
  )

proc dos_qabstracttablemodel_create(modelPtr: NimQAbstractTableModel,
                                    metaObject: DosQMetaObject,
                                    qobjectCallback: DosQObjectCallBack,
                                    qaimCallbacks: DosQAbstractItemModelCallbacks): DosQAbstractTableModel=
  let vtbl = new QAbstractTableModelVTable
  gen_qabstractitemmodel.QAbstractTableModel.setupCallbacks(
    modelPtr, metaObject, qobjectCallback, vtbl[], QAbstractTableModelmetacall
  )
  gen_qabstractitemmodel.QAbstractTableModel.setupCallbacks(
    modelPtr, qaimCallbacks, vtbl[]
  )

  gen_qabstractitemmodel.QAbstractTableModel.create(vtbl = vtbl)

proc dos_qabstracttablemodel_parent(modelPtr: DosQAbstractTableModel, index: DosQModelIndex): DosQModelIndex =
  QAbstractTableModel(modelPtr).parent(index)

proc dos_qabstracttablemodel_index(modelPtr: DosQAbstractTableModel, row: cint, column: cint, parent: DosQModelIndex): DosQModelIndex =
  QAbstractTableModel(modelPtr).index(row, column, parent)

proc dos_image_resizer(imagePath: cstring, maxSize: cint, tmpDirPath: cstring): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_plain_text(htmlString: cstring): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_escape_html(input: cstring): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_qurl_fromUserInput(input: cstring): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_qurl_host(host: cstring): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_qurl_replaceHostAndAddPath(url: cstring, newScheme: cstring, newHost: cstring, pathPrefix: cstring): cstring {.cdecl, dynlib: dynLibName, importc.}

# SingleInstance
proc dos_singleinstance_create(uniqueName: cstring, eventStr: cstring): DosQObject {.cdecl, dynlib: dynLibName, importc.}
proc dos_singleinstance_isfirst(vptr: DosQObject): bool {.cdecl, dynlib: dynLibName, importc.}
proc dos_singleinstance_delete(vptr: DosQObject) {.cdecl, dynlib: dynLibName, importc.}

# DosStatusEvent
proc dos_event_create_osThemeEvent(engine: DosQQmlApplicationEngine): DosStatusEvent {.cdecl, dynlib: dynLibName, importc.}
proc dos_event_create_urlSchemeEvent(): DosStatusEvent {.cdecl, dynlib: dynLibName, importc.}
proc dos_event_delete(vptr: DosStatusEvent) {.cdecl, dynlib: dynLibName, importc.}

# DosStatusOSNotification
proc dos_osnotification_create(): DosStatusOSNotification 
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_osnotification_show_notification(vptr: DosStatusOSNotification,
  title: cstring, messsage: cstring, identifier: cstring) 
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_osnotification_show_badge_notification(vptr: DosStatusOSNotification, notificationsCount: int) 
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_osnotification_delete(vptr: DosStatusOSNotification) 
  {.cdecl, dynlib: dynLibName, importc.}

# QSettings
proc dos_qsettings_create(fileName: cstring, format: int): DosQSettings 
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qsettings_value(vptr: DosQSettings, key: cstring, 
  defaultValue: DosQVariant): DosQVariant
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qsettings_set_value(vptr: DosQSettings, key: cstring, 
    value: DosQVariant)
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qsettings_remove(vptr: DosQSettings, key: cstring)
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qsettings_delete(vptr: DosQSettings) 
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qsettings_begin_group(vptr: DosQSettings, group: cstring) 
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qsettings_end_group(vptr: DosQSettings) 
  {.cdecl, dynlib: dynLibName, importc.}

# QTimer
proc dos_qtimer_create(): DosQTimer
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qtimer_delete(vptr: DosQTimer)
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qtimer_set_interval(vptr: DosQTimer, interval: int)
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qtimer_interval(vptr: DosQTimer): int
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qtimer_start(vptr: DosQTimer)
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qtimer_stop(vptr: DosQTimer)
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qtimer_set_single_shot(vptr: DosQTimer, singleShot: bool)
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qtimer_is_single_shot(vptr: DosQTimer): bool
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_qtimer_is_active(vptr: DosQTimer): bool
  {.cdecl, dynlib: dynLibName, importc.}

# DosStatusKeychainManager
proc dos_keychainmanager_create(service: cstring, authenticationReason: cstring): 
  DosStatusKeychainManager
  {.cdecl, dynlib: dynLibName, importc.}
proc dos_keychainmanager_read_data_sync(vptr: DosStatusKeychainManager,
  key: cstring): string {.cdecl, dynlib: dynLibName, importc.}
proc dos_keychainmanager_read_data_async(vptr: DosStatusKeychainManager,
  key: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_keychainmanager_store_data_async(vptr: DosStatusKeychainManager,
  key: cstring, data: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_keychainmanager_delete_data_async(vptr: DosStatusKeychainManager,
  key: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_keychainmanager_delete(vptr: DosStatusKeychainManager) 
  {.cdecl, dynlib: dynLibName, importc.}

# DosStatusSoundManager
proc dos_soundmanager_play_sound(soundUrl: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_soundmanager_set_player_volume(volume: int) {.cdecl, dynlib: dynLibName, importc.}
proc dos_soundmanager_stop_player() {.cdecl, dynlib: dynLibName, importc.}

proc dos_to_local_file(fileUrl: cstring): cstring
  {.cdecl, dynlib: dynLibName, importc.}

proc dos_from_local_file(filePath: cstring): cstring
  {.cdecl, dynlib: dynLibName, importc.}

proc dos_app_is_active(engine: DosQQmlApplicationEngine): bool {.cdecl, dynlib: dynLibName, importc.}
proc dos_app_make_it_active(engine: DosQQmlApplicationEngine) {.cdecl, dynlib: dynLibName, importc.}

# Common
proc dos_installMessageHandler(handler: DosMessageHandler) {.cdecl, dynlib: dynLibName, importc.}

{.pop.}
