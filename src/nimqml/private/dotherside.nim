import strutils

const dynLibName =
  case system.hostOS:
    of "windows":
      "DOtherSide.dll"
    of "macosx":
      "libDOtherSide.dylib"
    else:
      "libDOtherSide.so.0.6"

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
  DosRoleNamesCallback = proc(nimmodel: NimQAbstractItemModel, result: DosQHashIntByteArray) {.cdecl.}
  DosFlagsCallback = proc(nimmodel: NimQAbstractItemModel, index: DosQModelIndex, result: var cint) {.cdecl.}
  DosHeaderDataCallback = proc(nimmodel: NimQAbstractItemModel, section: cint, orientation: cint, role: cint, result: DosQVariant) {.cdecl.}
  DosIndexCallback = proc(nimmodel: NimQAbstractItemModel, row: cint, column: cint, parent: DosQModelIndex, result: DosQModelIndex) {.cdecl.}
  DosParentCallback = proc(nimmodel: NimQAbstractItemModel, child: DosQModelIndex, result: DosQModelIndex) {.cdecl.}
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

  DosMessageHandler = proc(messageType: cint, message: cstring, category: cstring, file: cstring, function: cstring, lint: cint) {.cdecl.}

# Conversion
proc resetToNil[T](x: var T) = x = nil.pointer.T
proc isNil(x: DosQMetaObject): bool = x.pointer.isNil
proc isNil(x: DosQVariant): bool = x.pointer.isNil
proc isNil(x: DosQObject): bool = x.pointer.isNil
proc isNil(x: DosQQmlApplicationEngine): bool = x.pointer.isNil
proc isNil(x: DosQUrl): bool = x.pointer.isNil
proc isNil(x: DosQQuickView): bool = x.pointer.isNil
proc isNil(x: DosQHashIntByteArray): bool = x.pointer.isNil
proc isNil(x: DosQModelIndex): bool = x.pointer.isNil

# CharArray
proc dos_chararray_delete(str: cstring) {.cdecl, dynlib: dynLibName, importc.}

# QGuiApplication
proc dos_qguiapplication_application_dir_path(): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_enable_hdpi(uiScaleFilePath: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_initialize_opengl() {.cdecl, dynlib: dynLibName, importc.}
proc dos_qtwebview_initialize() {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_try_enable_threaded_renderer() {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_create() {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_exec() {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_quit() {.cdecl, dynlib: dynLibName, importc.}
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
proc dos_qqmlapplicationengine_create(): DosQQmlApplicationEngine {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlapplicationengine_getNetworkAccessManager(engine: DosQQmlApplicationEngine): DosQQNetworkAccessManager {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlapplicationengine_setNetworkAccessManagerFactory(engine: DosQQmlApplicationEngine, factory: DosQQNetworkAccessManagerFactory) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlapplicationengine_load(engine: DosQQmlApplicationEngine, filename: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlapplicationengine_load_url(engine: DosQQmlApplicationEngine, url: DosQUrl) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlapplicationengine_load_data(engine: DosQQmlApplicationEngine, data: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlapplicationengine_add_import_path(engine: DosQQmlApplicationEngine, path: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlapplicationengine_context(engine: DosQQmlApplicationEngine): DosQQmlContext {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlapplicationengine_delete(engine: DosQQmlApplicationEngine) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qguiapplication_load_translation(engine: DosQQmlApplicationEngine, content: cstring, shouldRetranslate: bool) {.cdecl, dynlib: dynLibName, importc.}

# QVariant
proc dos_qvariant_create(): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_int(value: cint): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_uint(value: cuint): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_longlong(value: clonglong): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_ulonglong(value: culonglong): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_bool(value: bool): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_string(value: cstring): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_qobject(value: DosQObject): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_qvariant(value: DosQVariant): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_float(value: cfloat): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_create_double(value: cdouble): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_delete(variant: DosQVariant) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_isnull(variant: DosQVariant): bool {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_toInt(variant: DosQVariant): cint {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_toUInt(variant: DosQVariant): cuint {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_toLongLong(variant: DosQVariant): clonglong {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_toULongLong(variant: DosQVariant): culonglong {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_toBool(variant: DosQVariant): bool {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_toString(variant: DosQVariant): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_toDouble(variant: DosQVariant): cdouble {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_toFloat(variant: DosQVariant): cfloat {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_setInt(variant: DosQVariant, value: cint) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_setUInt(variant: DosQVariant, value: cuint) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_setLongLong(variant: DosQVariant, value: clonglong) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_setULongLong(variant: DosQVariant, value: culonglong) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_setBool(variant: DosQVariant, value: bool) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_setString(variant: DosQVariant, value: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_assign(leftValue: DosQVariant, rightValue: DosQVariant) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_setFloat(variant: DosQVariant, value: cfloat) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_setDouble(variant: DosQVariant, value: cdouble) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qvariant_setQObject(variant: DosQVariant, value: DosQObject) {.cdecl, dynlib: dynLibName, importc.}

# QObject
proc dos_qobject_qmetaobject(): DosQMetaObject {.cdecl, dynlib: dynLibName, importc.}
proc dos_qobject_create(nimobject: NimQObject, metaObject: DosQMetaObject, dosQObjectCallback: DosQObjectCallBack): DosQObject {.cdecl, dynlib: dynLibName, importc.}
proc dos_qobject_objectName(qobject: DosQObject): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_qobject_setObjectName(qobject: DosQObject, name: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qobject_signal_emit(qobject: DosQObject, signalName: cstring, argumentsCount: cint, arguments: ptr DosQVariantArray) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qobject_delete(qobject: DosQObject) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qobject_signal_connect(sender: DosQObject, signalName: cstring, receiver: DosQObject, slot: cstring, signalType: cint) {.cdecl, dynlib: dynLibName, importc.}

# QAbstractItemModel
proc dos_qabstractitemmodel_qmetaobject(): DosQMetaObject {.cdecl dynlib: dynLibName, importc.}

# QMetaObject
proc dos_qmetaobject_create(superclassMetaObject: DosQMetaObject,
                            className: cstring,
                            signalDefinitions: ptr DosSignalDefinitions,
                            slotDefinitions: ptr DosSlotDefinitions,
                            propertyDefinitions: ptr DosPropertyDefinitions): DosQMetaObject {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmetaobject_delete(vptr: DosQMetaObject) {.cdecl, dynlib: dynLibName, importc.}

# status-go signal handler
proc dos_signal(vptr: pointer, signal: cstring, slot: cstring) {.cdecl, dynlib: dynLibName, importc.}

# QUrl
proc dos_qurl_create(url: cstring, parsingMode: cint): DosQUrl {.cdecl, dynlib: dynLibName, importc.}
proc dos_qurl_delete(vptr: DosQUrl) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qurl_to_string(vptr: DosQUrl): cstring {.cdecl, dynlib: dynLibName, importc.}

# QNetworkConfigurationManager
proc dos_qncm_create(): DosQObject {.cdecl, dynlib: dynLibName, importc.}
proc dos_qncm_delete(vptr: DosQObject) {.cdecl, dynlib: dynLibName, importc.}

# QNetworkAccessManagerFactory
proc dos_qqmlnetworkaccessmanagerfactory_create(tmpPath: cstring): DosQQNetworkAccessManagerFactory {.cdecl, dynlib: dynLibName, importc.}

# QNetworkAccessManager
proc dos_qqmlnetworkaccessmanager_clearconnectioncache(vptr: DosQQNetworkAccessManager) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qqmlnetworkaccessmanager_setnetworkaccessible(vptr: DosQQNetworkAccessManager, accessible: cint) {.cdecl, dynlib: dynLibName, importc.}

# QQuickView
proc dos_qquickview_create(): DosQQuickView {.cdecl, dynlib: dynLibName, importc.}
proc dos_qquickview_delete(view: DosQQuickView) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qquickview_show(view: DosQQuickView) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qquickview_source(view: DosQQuickView): cstring {.cdecl, dynlib: dynLibName, importc.}
proc dos_qquickview_set_source(view: DosQQuickView, filename: cstring) {.cdecl, dynlib: dynLibName, importc.}

# QHash<int, QByteArra>
proc dos_qhash_int_qbytearray_create(): DosQHashIntByteArray {.cdecl, dynlib: dynLibName, importc.}
proc dos_qhash_int_qbytearray_delete(qHash: DosQHashIntByteArray) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qhash_int_qbytearray_insert(qHash: DosQHashIntByteArray, key: int, value: cstring) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qhash_int_qbytearray_value(qHash: DosQHashIntByteArray, key: int): cstring {.cdecl, dynlib: dynLibName, importc.}

# QModelIndex
proc dos_qmodelindex_create(): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_create_qmodelindex(other: DosQModelIndex): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_delete(modelIndex: DosQModelIndex) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_row(modelIndex: DosQModelIndex): cint {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_column(modelIndex: DosQModelIndex): cint {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_isValid(modelIndex: DosQModelIndex): bool {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_data(modelIndex: DosQModelIndex, role: cint): DosQVariant {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_parent(modelIndex: DosQModelIndex): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_child(modelIndex: DosQModelIndex, row: cint, column: cint): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_sibling(modelIndex: DosQModelIndex, row: cint, column: cint): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_assign(leftSide: DosQModelIndex, rightSide: DosQModelIndex) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qmodelindex_internalPointer(modelIndex: DosQModelIndex): pointer {.cdecl, dynlib: dynLibName, importc.}

# QAbstractItemModel
proc dos_qabstractitemmodel_create(modelPtr: NimQAbstractItemModel,
                                   metaObject: DosQMetaObject,
                                   qobjectCallback: DosQObjectCallBack,
                                   qaimCallbacks: DosQAbstractItemModelCallbacks): DosQAbstractItemModel {.cdecl, dynlib: dynLibName, importc.}

proc dos_qabstractitemmodel_beginInsertRows(model: DosQAbstractItemModel,
                                            parentIndex: DosQModelIndex,
                                            first: cint,
                                            last: cint) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_endInsertRows(model: DosQAbstractItemModel) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_beginRemoveRows(model: DosQAbstractItemModel,
                                            parentIndex: DosQModelIndex,
                                            first: cint,
                                            last: cint) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_endRemoveRows(model: DosQAbstractItemModel) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_beginMoveRows(model: DosQAbstractItemModel,
                                            sourceParentIndex: DosQModelIndex, sourceFirst: cint, sourceLast: cint,
                                            destParentIndex: DosQModelIndex, destinationChild: cint) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_endMoveRows(model: DosQAbstractItemModel) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_beginInsertColumns(model: DosQAbstractItemModel,
                                               parentIndex: DosQModelIndex,
                                               first: cint,
                                               last: cint) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_endInsertColumns(model: DosQAbstractItemModel) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_beginRemoveColumns(model: DosQAbstractItemModel,
                                               parentIndex: DosQModelIndex,
                                               first: cint,
                                               last: cint) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_endRemoveColumns(model: DosQAbstractItemModel) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_beginResetModel(model: DosQAbstractItemModel) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_endResetModel(model: DosQAbstractItemModel) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_dataChanged(model: DosQAbstractItemModel,
                                        parentLeft: DosQModelIndex,
                                        bottomRight: DosQModelIndex,
                                        rolesArrayPtr: ptr cint,
                                        rolesArrayLength: cint) {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_createIndex(model: DosQAbstractItemModel, row: cint, column: cint, data: pointer): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_hasChildren(model: DosQAbstractItemModel, parent: DosQModelIndex): bool {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_hasIndex(model: DosQAbstractItemModel, row: int, column: int, parent: DosQModelIndex): bool {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_canFetchMore(model: DosQAbstractItemModel, parent: DosQModelIndex): bool {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractitemmodel_fetchMore(model: DosQAbstractItemModel, parent: DosQModelIndex) {.cdecl, dynlib: dynLibName, importc.}


# QResource
proc dos_qresource_register(filename: cstring) {.cdecl, dynlib: dynLibName, importc.}

# QDeclarative
proc dos_qdeclarative_qmlregistertype(value: ptr DosQmlRegisterType): cint {.cdecl, dynlib: dynLibName, importc.}
proc dos_qdeclarative_qmlregistersingletontype(value: ptr DosQmlRegisterType): cint {.cdecl, dynlib: dynLibName, importc.}

# QAbstractListModel
proc dos_qabstractlistmodel_qmetaobject(): DosQMetaObject {.cdecl dynlib: dynLibName, importc.}

proc dos_qabstractlistmodel_create(modelPtr: NimQAbstractListModel,
                                   metaObject: DosQMetaObject,
                                   qobjectCallback: DosQObjectCallBack,
                                   qaimCallbacks: DosQAbstractItemModelCallbacks): DosQAbstractListModel {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractlistmodel_columnCount(modelPtr: DosQAbstractListModel, index: DosQModelIndex): cint {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractlistmodel_parent(modelPtr: DosQAbstractListModel, index: DosQModelIndex): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstractlistmodel_index(modelPtr: DosQAbstractListModel, row: cint, column: cint, parent: DosQModelIndex): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}

# QAbstractTableModel
proc dos_qabstracttablemodel_qmetaobject(): DosQMetaObject {.cdecl dynlib: dynLibName, importc.}
proc dos_qabstracttablemodel_create(modelPtr: NimQAbstractTableModel,
                                    metaObject: DosQMetaObject,
                                    qobjectCallback: DosQObjectCallBack,
                                    qaimCallbacks: DosQAbstractItemModelCallbacks): DosQAbstractTableModel {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstracttablemodel_parent(modelPtr: DosQAbstractTableModel, index: DosQModelIndex): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}
proc dos_qabstracttablemodel_index(modelPtr: DosQAbstractTableModel, row: cint, column: cint, parent: DosQModelIndex): DosQModelIndex {.cdecl, dynlib: dynLibName, importc.}

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

proc dos_to_local_file(fileUrl: cstring): cstring
  {.cdecl, dynlib: dynLibName, importc.}

proc dos_from_local_file(filePath: cstring): cstring
  {.cdecl, dynlib: dynLibName, importc.}

proc dos_app_is_active(engine: DosQQmlApplicationEngine): bool {.cdecl, dynlib: dynLibName, importc.}
proc dos_app_make_it_active(engine: DosQQmlApplicationEngine) {.cdecl, dynlib: dynLibName, importc.}

# Common
proc dos_installMessageHandler(handler: DosMessageHandler) {.cdecl, dynlib: dynLibName, importc.}
