import
  gen_qabstractitemdelegate,
  gen_qabstractitemmodel,
  gen_qapplication,
  gen_qmetatype,
  gen_qmetaobject,
  gen_qobject,
  gen_qobjectdefs,
  gen_qresource,
  gen_qurl,
  gen_qvariant,
  quick/gen_qqmlapplicationengine,
  quick/gen_qqmlcomponent,
  quick/gen_qqmlcontext,
  quick/gen_qquickview

import std/[macros, sequtils, strutils, tables], gen_qmetatype, gen_qobjectdefs

from system/ansi_c import c_calloc, c_malloc, c_free

const
  AccessPrivate = cuint 0x00
  AccessProtected = cuint 0x01
  AccessPublic = cuint 0x02
  AccessMask = cuint 0x03

  MethodMethod = cuint 0x00
  MethodSignal = cuint 0x04
  MethodSlot = cuint 0x08
  MethodConstructor = cuint 0x0c
  MethodTypeMask = cuint 0x0c

  MethodCompatibility = cuint 0x10
  MethodCloned = cuint 0x20
  MethodScriptable = cuint 0x40
  MethodRevisioned = cuint 0x80

  # PropertyFlags
  Invalid = cuint 0x00000000
  Readable = cuint 0x00000001
  Writable = cuint 0x00000002
  Resettable = cuint 0x00000004
  EnumOrFlag = cuint 0x00000008
  StdCppSet = cuint 0x00000100
  Constant = cuint 0x00000400
  Final = cuint 0x00000800
  Designable = cuint 0x00001000
  ResolveDesignable = cuint 0x00002000
  Scriptable = cuint 0x00004000
  ResolveScriptable = cuint 0x00008000
  Stored = cuint 0x00010000
  ResolveStored = cuint 0x00020000
  Editable = cuint 0x00040000
  ResolveEditable = cuint 0x00080000
  User = cuint 0x00100000
  ResolveUser = cuint 0x00200000
  Notify = cuint 0x00400000
  Revisioned = cuint 0x00800000
  Required = cuint 0x01000000

  # QMetaObjectPrivate offsets (5.15)
  revisionPos = 0
  classNamePos = 1
  classInfoCountPos = 2
  classInfoDataPos = 3
  methodCountPos = 4
  methodDataPos = 5
  propertyCountPos = 6
  propertyDataPos = 7
  enumCountPos = 8
  enumDataPos = 9
  constructorCountPos = 10
  constructorDataPos = 11
  flagsPos = 12
  signalCountPos = 13
  QMetaObjectPrivateElems = 14

  QMetaObjectRevision = 8
    # 7 == 5.0
    # 8 == 5.12

type
  QMetaObjectData = object
    superdata: pointer
    stringdata: pointer
    data: ptr cuint
    static_metacall: pointer
    relatedMetaObjects: pointer
    extradata: pointer

  QByteArrayData = object
    refcount: cint # atomic..
    size: cuint
    alloc: uint32 # bitfield...
    offset: uint # ptrdiff_t

  ParamDef* = object
    name*: string
    metaType*: cint

  MethodDef* = object
    name*: string
    returnMetaType*: cint
    params*: seq[ParamDef]
    flags*: cuint

  PropertyDef* = object
    name*: string
    metaType*: cint
    readSlot*, writeSlot*, notifySignal*: string

  QObjectDef* = object
    name*: string
    signals*: seq[MethodDef]
    slots*: seq[MethodDef]
    properties*: seq[PropertyDef]

template usizeof(T): untyped =
  cuint(sizeof(T))

func toQtType*(metaType: cint): string =
  # TODO autogenerate - has to be callable from VM
  case metaType
  of QMetaTypeTypeEnum.Void: "void"
  of QMetaTypeTypeEnum.Bool: "bool"
  of QMetaTypeTypeEnum.LongLong: "qlonglong"
  of QMetaTypeTypeEnum.QString: "QString"
  of QMetaTypeTypeEnum.QObjectStar: "QObject*"
  else: raiseAssert "Unknown metatype " & $metaType

func isSignal*(m: MethodDef): bool =
  (m.flags and MethodSignal) > 0
func isSlot*(m: MethodDef): bool =
  (m.flags and MethodSlot) > 0

proc signalDef*(
    _: type MethodDef, name: string, params: openArray[ParamDef]
): MethodDef =
  MethodDef(
    name: name,
    params: @params,
    returnMetaType: QMetaTypeTypeEnum.Void,
    flags: MethodSignal or AccessPublic,
  )

proc slotDef*(
    _: type MethodDef, name: string, returnMetaType: cint, params: openArray[ParamDef]
): MethodDef =
  MethodDef(
    name: name,
    params: @params,
    returnMetaType: returnMetaType,
    flags: MethodSlot or AccessPublic,
  )

proc signature*(m: MethodDef): string =
  m.name & "(" & m.params.mapIt(it.metaType.toQtType()).join(",") & ")"

proc genMetaObjectData*(
    className: string,
    signals: openArray[MethodDef],
    slots: openArray[MethodDef],
    props: openArray[PropertyDef],
): (seq[cuint], seq[byte]) =
  # Class names need to be globally unique
  # TODO use something other than a thread var
  var counter {.threadvar.}: CountTable[string]

  let c = counter.getOrDefault(className, 0)
  counter.inc(className)

  let
    className = className & (if c > 0: $c else: "")
    methods = @signals & @slots
    methodCount = cuint(methods.len())
    methodParamsSize = cuint(foldl(methods, a + b.params.len, 0)) * 2 + methodCount

    hasNotifySignals = anyIt(props, it.notifySignal.len > 0)
    metaSize =
      QMetaObjectPrivateElems + methodCount * 5 + methodParamsSize + cuint(
        props.len * 3
      ) + cuint(ord(hasNotifySignals)) * cuint(props.len) + 1

  var data = newSeq[cuint](metaSize.int)
  data[revisionPos] = QMetaObjectRevision

  var dataIndex = cuint QMetaObjectPrivateElems
  var paramsIndex = cuint(0)

  block: # classinfo
    discard

  block: # methods
    data[methodCountPos] = methodCount
    data[methodDataPos] = dataIndex
    dataIndex += 5 * methodCount

    paramsIndex = dataIndex
    dataIndex += methodParamsSize

    data[propertyCountPos] = cuint(props.len)
    data[propertyDataPos] = dataIndex

    dataIndex += 3 * data[propertyCountPos]
    if hasNotifySignals:
      dataIndex += data[propertyCountPos]

    data[signalCountPos] = cuint signals.len

  dataIndex = QMetaObjectPrivateElems

  var
    strings: OrderedTable[string, int]
    indices: seq[QByteArrayData]
    stringtmp: string

  template addString(s: untyped): cuint =
    let slen = strings.len()
    let pos = strings.mgetOrPut($s, strings.len)
    if strings.len > slen:
      indices.add(QByteArrayData(refcount: -1, size: cuint(len(s))))

      stringtmp.add s
      stringtmp.add '\0'
    pos.cuint

  block:
    discard addString(className)

  block: # Methods and their parameters
    for m in methods:
      data[dataIndex] = addString(m.name)
      data[dataIndex + 1] = cuint m.params.len
      data[dataIndex + 2] = paramsIndex
      data[dataIndex + 3] = addString("") # TODO tag
      data[dataIndex + 4] = m.flags
      dataIndex += 5
      paramsIndex += 1 + cuint m.params.len * 2

  block: # Return types
    for m in methods:
      # TODO moc does not allow return-by-reference, replacing it with void:
      # https://github.com/openwebos/qt/blob/92fde5feca3d792dfd775348ca59127204ab4ac0/src/tools/moc/moc.cpp#L400
      data[dataIndex] = cuint m.returnMetaType
      dataIndex += 1
      for p in m.params:
        data[dataIndex] = cuint p.metaType # TODO builtin?
        dataIndex += 1

      for p in m.params:
        data[dataIndex] = addString p.name # TODO builtin?
        dataIndex += 1

  block: # Properties
    for p in props:
      data[dataIndex] = addString(p.name)
      data[dataIndex + 1] = cuint p.metaType
      data[dataIndex + 2] = block:
        var v = Scriptable or Designable or Stored or Editable
        if p.readSlot.len > 0:
          v = v or Readable
        if p.writeSlot.len > 0:
          v = v or Writable
        if p.notifySignal.len > 0:
          v = v or Notify
        if p.writeSlot.len == 0 and p.notifySignal.len == 0:
          v = v or Constant
        v

      dataIndex += 3

  if hasNotifySignals:
    for p in props:
      if p.notifySignal.len > 0:
        var x = cuint 0
        for m in methods.filterIt(it.isSignal):
          if m.name == p.notifySignal:
            break
          x += 1
        data[dataIndex] = x
      else:
        data[dataIndex] = 0
      dataIndex += 1

  dataIndex += 1

  var offset = cuint(sizeof(QByteArrayData) * strings.len)
  for i in 0 ..< indices.len:
    indices[i].offset = offset
    offset -= usizeof(QByteArrayData)
    offset += indices[i].size + 1

  var
    stringdata = newSeq[byte](strings.len * sizeof(QByteArrayData) + stringtmp.len)
    pos = 0

  for i in 0 ..< indices.len:
    assert(sizeof(QByteArrayData) == 24)

    proc toBytes(v: SomeInteger): array[sizeof(v), byte] =
      # VM can't do casts :/
      for i in 0 ..< sizeof(result):
        result[i] = byte((v shr (i * 8)) and 0xff)

    stringdata[pos ..< pos + 3] = toBytes(cast[cuint](indices[i].refcount))
    pos += 4

    stringdata[pos ..< pos + 3] = toBytes(cast[cuint](indices[i].size))
    pos += 4

    stringdata[pos ..< pos + 3] = toBytes(cast[cuint](indices[i].alloc))
    pos += 4

    pos += 4 # Alignment

    stringdata[pos ..< pos + 7] = toBytes(cast[uint](indices[i].offset))
    pos += 8

  let pstrings = sizeof(QByteArrayData) * strings.len

  for i, c in stringtmp:
    stringdata[pstrings + i] = byte(stringtmp[i])

  (data, stringdata)

proc createMetaObject*(
    superclassMetaObject: gen_qobjectdefs_types.QMetaObject,
    data: openArray[cuint],
    stringdata: seq[byte],
): gen_qobjectdefs.QMetaObject =
  let
    superdata = superclassMetaObject.h
    dataBytes = data.len * sizeof(cuint)
    blob = cast[ptr UncheckedArray[byte]](c_malloc(csize_t(dataBytes + stringdata.len)))

  copyMem(addr blob[0], addr data[0], dataBytes)
  copyMem(addr blob[dataBytes], addr stringdata[0], stringdata.len())

  var metaObjectData = QMetaObjectData(
    superdata: superdata,
    data: cast[ptr cuint](addr blob[0]),
    stringdata: addr blob[dataBytes],
  )

  let tmp = gen_qobjectdefs.QMetaObject.create()
  copyMem(tmp.h, addr metaObjectData, sizeof(QMetaObjectData))
  tmp

proc genMetaObject*(
    superclassMetaObject: gen_qobjectdefs_types.QMetaObject,
    className: string,
    signals, slots: openArray[MethodDef],
    props: openArray[PropertyDef],
): gen_qobjectdefs_types.QMetaObject =
  let (data, stringdata) = genMetaObjectData(className, signals, slots, props)
  createMetaObject(superclassMetaObject, data, stringdata)

import std/sequtils

converter toQAbstractItemModel*(
    v: gen_qabstractitemmodel_types.QAbstractItemModel
): DosQAbstractItemModel =
  DosQAbstractItemModel(v.h)

converter toQAbstractItemModel*(
    v: DosQAbstractItemModel
): gen_qabstractitemmodel_types.QAbstractItemModel =
  gen_QAbstractItemModel_types.QAbstractItemModel(h: pointer(v))

converter toQAbstractListModel*(
    v: gen_qabstractitemmodel_types.QAbstractListModel
): DosQAbstractListModel =
  DosQAbstractListModel(v.h)

converter toQAbstractListModel*(
    v: DosQAbstractListModel
): gen_qabstractitemmodel_types.QAbstractListModel =
  gen_QAbstractItemModel_types.QAbstractListModel(h: pointer(v))

converter toQAbstractTableModel*(
    v: gen_qabstractitemmodel_types.QAbstractTableModel
): DosQAbstractTableModel =
  DosQAbstractTableModel(v.h)

converter toQAbstractTableModel*(
    v: DosQAbstractTableModel
): gen_qabstractitemmodel_types.QAbstractTableModel =
  gen_QAbstractItemModel_types.QAbstractTableModel(h: pointer(v))

converter toQQmlApplicationEngine*(
    v: gen_qqmlapplicationengine_types.QQmlApplicationEngine
): DosQQmlApplicationEngine =
  DosQQmlApplicationEngine(v.h)

converter toQQmlApplicationEngine*(
    v: DosQQmlApplicationEngine
): gen_qqmlapplicationengine_types.QQmlApplicationEngine =
  gen_qqmlapplicationengine_types.QQmlApplicationEngine(h: pointer(v))

converter toQQmlContext*(v: gen_qqmlcontext_types.QQmlContext): DosQQmlContext =
  DosQQmlContext(v.h)

converter toQQmlContext*(v: DosQQmlContext): gen_qqmlcontext_types.QQmlContext =
  gen_qqmlcontext_types.QQmlContext(h: pointer(v))

converter toQQmlEngine*(v: DosQQmlApplicationEngine): gen_qQmlEngine_types.QQmlEngine =
  gen_qQmlEngine_types.QQmlEngine(h: pointer(v))

converter toQMetaObject*(v: gen_qobjectdefs_types.QMetaObject): DosQMetaObject =
  DosQMetaObject(v.h)

converter toQMetaObject*(v: DosQMetaObject): gen_qobjectdefs_types.QMetaObject =
  gen_qobjectdefs_types.QMetaObject(h: pointer(v))

converter toQMetaObjectConnection*(
    v: gen_qobjectdefs_types.QMetaObjectConnection
): DosQMetaObjectConnection =
  DosQMetaObjectConnection(v.h)

converter toQMetaObjectConnection*(
    v: DosQMetaObjectConnection
): gen_qobjectdefs_types.QMetaObjectConnection =
  gen_qobjectdefs_types.QMetaObjectConnection(h: pointer(v))

converter toQModelIndex*(v: gen_qabstractitemmodel_types.QModelIndex): DosQModelIndex =
  DosQModelIndex(v.h)

converter toQModelIndex*(v: DosQModelIndex): gen_qabstractitemmodel_types.QModelIndex =
  gen_qabstractitemmodel_types.QModelIndex(h: pointer(v))

converter toQObject*(v: gen_qobject_types.QObject): DosQObject =
  DosQObject(v.h)

converter toQObject*(v: DosQObject): gen_qobject_types.QObject =
  gen_qobject_types.QObject(h: pointer(v))

converter toQUrl*(v: gen_qurl_types.QUrl): DosQUrl =
  DosQUrl(v.h)

converter toQQrl*(v: DosQUrl): gen_qurl_types.QUrl =
  gen_qurl_types.QUrl(h: pointer(v))

converter toQVariant*(v: gen_qvariant_types.QVariant): DosQVariant =
  DosQVariant(v.h)

converter toQVariant*(v: DosQVariant): gen_qvariant.QVariant =
  gen_qvariant_types.QVariant(h: pointer(v))

from system/ansi_c import c_calloc, c_free

# TODO Get rid of this - but it requires changing the dos_* interface significantly
import std/tables
var classProps {.threadvar.}: Table[string, QMetaMethod]

proc classLookup(mo: gen_qobjectdefs_types.QMetaObject, id: cint, read: bool): string =
  repr(mo.h) & $id & $read

proc findProp(
    mo: gen_qobjectdefs_types.QMetaObject, id: cint, read: bool
): QMetaMethod =
  try:
    classProps[classLookup(mo, id, read)]
  except CatchableError as exc:
    raiseAssert exc.msg

template noExceptions(body: untyped): untyped =
  try:
    {.gcsafe.}:
      body
  except Defect as e:
    raise e
  except Exception as e:
    raiseAssert(e.msg & "\n" & e.getStackTrace())

proc nos_qmetaobject_create(
    superclassMetaObject: gen_qobjectdefs_types.QMetaObject,
    className: cstring,
    signalDefinitions: ptr DosSignalDefinitions,
    slotDefinitions: ptr DosSlotDefinitions,
    propertyDefinitions: ptr DosPropertyDefinitions,
): DosQMetaObject =
  template params(
      s: DosSignalDefinition | DosSlotDefinition
  ): openArray[DosParameterDefinition] =
    let p = cast[ptr UncheckedArray[DosParameterDefinition]](s.parameters)
    p.toOpenArray(0, s.parametersCount.int - 1)

  let
    signalDefs =
      cast[ptr UncheckedArray[DosSignalDefinition]](signalDefinitions.definitions)
    slotDefs = cast[ptr UncheckedArray[DosSlotDefinition]](slotDefinitions.definitions)
    propertyDefs =
      cast[ptr UncheckedArray[DosPropertyDefinition]](propertyDefinitions.definitions)

    signals = mapIt(
      signalDefs.toOpenArray(0, signalDefinitions.count.int - 1),
      MethodDef.signalDef(
        $it.name, it.params.mapIt(ParamDef(name: $it.name, metaType: it.metaType))
      ),
    )
    slots = mapIt(
      slotDefs.toOpenArray(0, slotDefinitions.count.int - 1),
      MethodDef.slotDef(
        $it.name,
        it.returnMetaType,
        it.params.mapIt(ParamDef(name: $it.name, metaType: it.metaType)),
      ),
    )
    props = mapIt(
      propertyDefs.toOpenArray(0, propertyDefinitions.count.int - 1),
      PropertyDef(
        name: $it.name,
        metaType: it.propertyMetaType,
        readSlot: $it.readSlot,
        writeSlot: $it.writeSlot,
        notifySignal: $it.notifySignal,
      ),
    )

  let tmp = genMetaObject(superclassMetaObject, $className, signals, slots, props)

  block:
    for i in 0 ..< propertyDefinitions.count:
      let prop = propertyDefs[i]
      if prop.readSlot != nil:
        for j in 0 ..< slotDefinitions.count:
          if slotDefs[j].name == prop.readSlot:
            classProps[classLookup(tmp, i, true)] = tmp.methodX(
              superclassMetaObject.methodCount() + j + signalDefinitions.count
            )

      if prop.writeSlot != nil:
        for j in 0 ..< slotDefinitions.count:
          if slotDefs[j].name == prop.writeSlot:
            classProps[classLookup(tmp, i, false)] = tmp.methodX(
              superclassMetaObject.methodCount() + j + signalDefinitions.count
            )

  tmp

template setupCallbacks[MC](
    T: type,
    nimobjectParam: NimQObject,
    metaObjectParam: DosQMetaObject,
    dosQObjectCallbackParam: DosQObjectCallBack,
    vtbl: auto,
    superMc: proc(self: MC, c: cint, index: cint, param3: pointer): cint {.
      raises: [], nimcall
    .},
) =
  func fromBytes(_: type string, v: openArray[byte]): string =
    if v.len > 0:
      result = newString(v.len)
      when nimvm:
        for i, c in v:
          result[i] = cast[char](c)
      else:
        copyMem(addr result[0], unsafeAddr v[0], v.len)

  vtbl.metacall = proc(
      self: T, c: cint, index: cint, param3: pointer
  ): cint {.closure, raises: [], gcsafe.} =
    let id = superMc(self, c, index, param3)
    if id < 0:
      return id

    let mo = metaObjectParam

    template callQObjectCallback(meth: QMetaMethod, offset: int) =
      let name = gen_qvariant.QVariant.create(string.fromBytes(meth.name()))
      var args = newSeq[DosQVariant](meth.parameterCount() + 1)
      args[0] = gen_qvariant.QVariant.create()

      for i in cint(0) ..< meth.parameterCount():
        args[i + 1] =
          gen_qvariant.QVariant.create(meth.parameterType(i), argv[int(i + offset)])
      dosQObjectCallbackParam(
        nimobjectParam, name, cint args.len, cast[ptr DosQVariantArray](addr args[0])
      )
      if meth.returnType() != QMetaTypeTypeEnum.Void and args[0].isValid():
        discard QMetaType.construct(meth.returnType(), argv[0], args[0].constData())

      for v in args:
        v.delete()

    noExceptions:
      var argv {.inject.} = cast[ptr UncheckedArray[pointer]](param3)
      case c
      of QMetaObjectCallEnum.InvokeMetaMethod:
        if index < mo.methodCount():
          let meth = mo.methodX(index)
          callQObjectCallback(meth, 1)

        id - (mo.methodCount() - mo.methodOffset())
      of QMetaObjectCallEnum.RegisterMethodArgumentMetaType:
        id - (mo.methodCount() - mo.methodOffset())
      of QMetaObjectCallEnum.ReadProperty:
        if index < mo.propertyCount():
          let property = mo.property(index)
          if property.isValid() and property.isReadable():
            let meth = findProp(mo, id, true)
            callQObjectCallback(meth, 1)

        id - (mo.propertyCount() - mo.propertyOffset())
      of QMetaObjectCallEnum.WriteProperty:
        if index < mo.propertyCount():
          let property = mo.property(index)
          if property.isValid() and property.isWritable():
            let meth = findProp(mo, id, false)
            callQObjectCallback(meth, 0)

        id - (mo.propertyCount() - mo.propertyOffset())
      of QMetaObjectCallEnum.ResetProperty,
          QMetaObjectCallEnum.RegisterPropertyMetaType,
          QMetaObjectCallEnum.QueryPropertyDesignable,
          QMetaObjectCallEnum.QueryPropertyScriptable,
          QMetaObjectCallEnum.QueryPropertyStored,
          QMetaObjectCallEnum.QueryPropertyEditable,
          QMetaObjectCallEnum.QueryPropertyUser:
        id - (mo.propertyCount() - mo.propertyOffset())
      else:
        id

  vtbl.metaObject = proc(
      self: T
  ): gen_qobjectdefs.QMetaObject {.closure, raises: [], gcsafe.} =
    metaObjectParam

template setupCallbacks(
    T: type,
    modelPtr: NimQAbstractListModel,
    qaimCallbacks: DosQAbstractItemModelCallbacks,
    vtbl:
      QAbstractItemModelVTable | QAbstractListModelVTable | QAbstractTableModelVtable,
) =
  if qaimCallbacks.rowCount != nil:
    vtbl.rowCount = proc(self: T, parent: QModelIndex): cint =
      noExceptions:
        var v: cint
        qaimCallbacks.rowCount(modelPtr, parent, v)
        v

  when T is gen_qabstractitemmodel.QAbstractTableModel:
    if qaimCallbacks.columnCount != nil:
      vtbl.columnCount = proc(self: T, parent: QModelIndex): cint =
        noExceptions:
          var v: cint
          qaimCallbacks.columnCount(modelPtr, parent, v)
          v

  if qaimCallbacks.data != nil:
    vtbl.data = proc(self: T, index: QModelIndex, role: cint): gen_qvariant.QVariant =
      noExceptions:
        var v = gen_qvariant.QVariant.create()
        qaimCallbacks.data(modelPtr, index, role, v)
        v

  if qaimCallbacks.setData != nil:
    vtbl.setData = proc(
        self: T, index: QModelIndex, value: gen_qvariant.QVariant, role: cint
    ): bool =
      noExceptions:
        var v: bool
        qaimCallbacks.setData(modelPtr, index, value, role, v)
        v

  if qaimCallbacks.roleNames != nil:
    vtbl.roleNames = proc(self: T): tables.Table[cint, seq[byte]] =
      noExceptions:
        qaimCallbacks.roleNames(modelPtr)

  if qaimCallbacks.flags != nil:
    vtbl.flags = proc(self: T, index: QModelIndex): cint =
      noExceptions:
        var v: cint
        qaimCallbacks.flags(modelPtr, index, v)
        v

  if qaimCallbacks.headerData != nil:
    vtbl.headerData = proc(
        self: T, section: cint, orientation: cint, role: cint
    ): gen_qvariant.QVariant =
      noExceptions:
        var v = gen_qvariant.QVariant.create()
        qaimCallbacks.headerData(modelPtr, section, orientation, role, v)
        v
  if qaimCallbacks.index != nil:
    vtbl.index =
      when T is QAbstractItemModel:
        proc(
            self: T, row: cint, column: cint, parent: QModelIndex
        ): QModelIndex {.closure.} =
          noExceptions:
            var v: DosQModelIndex
            qaimCallbacks.index(modelPtr, row, column, parent, v)
            v
      else:
        proc(
            self: T, row: cint, column: cint, parent: QModelIndex
        ): QModelIndex {.closure.} =
          noExceptions:
            var v: DosQModelIndex
            qaimCallbacks.index(modelPtr, row, column, parent, v)
            v

  when T isnot gen_qabstractitemmodel.QAbstractListModel and
      T isnot gen_qabstractitemmodel.QAbstractTableModel:
    if qaimCallbacks.parent != nil:
      vtbl.parent = proc(self: T, child: QModelIndex): QModelIndex =
        noExceptions:
          var v: DosQModelIndex
          qaimCallbacks.parent(modelPtr, child, v)
          v

    if qaimCallbacks.hasChildren != nil:
      vtbl.hasChildren = proc(self: T, child: QModelIndex): bool =
        noExceptions:
          var v: bool
          qaimCallbacks.hasChildren(modelPtr, child, v)
          v

  if qaimCallbacks.canFetchMore != nil:
    vtbl.canFetchMore = proc(self: T, parentX: QModelIndex): bool {.closure, gcsafe.} =
      noExceptions:
        var v: bool
        qaimCallbacks.canFetchMore(modelPtr, parentX, v)
        v

  if qaimCallbacks.fetchMore != nil:
    vtbl.fetchMore = proc(self: T, parentX: QModelIndex) {.closure, gcsafe.} =
      noExceptions:
        qaimCallbacks.fetchMore(modelPtr, parentX)

proc nos_qobject_connect_lambda_with_context_static(
    sender: gen_qobject_types.QObject,
    senderFunc: cstring,
    context: gen_qobject_types.QObject,
    callback: DosQObjectConnectLambdaCallback,
    data: pointer,
    connectionType: cint,
): gen_qobjectdefs_types.QMetaObjectConnection =
  var meta = sender.metaObject()
  var senderFunc = $senderFunc
  let meth = meta.methodX(meta.indexOfSignal(cstring(senderFunc[1 ..^ 1])))
  let numArguments = meth.parameterCount()

  var tmp = new QObject_connectSlot
  tmp[] = proc(argv: pointer) =
    let argv = cast[ptr UncheckedArray[pointer]](argv)
    var args = newSeq[DosQVariant](meth.parameterCount())
    for i in cint(0) ..< cint(args.len):
      args[i] = gen_qvariant.QVariant.create(meth.parameterType(i), argv[int(i) + 1])
    noExceptions:
      callback(data, cint args.len, cast[ptr DosQVariantArray](addr args[0]))

  GC_ref(tmp)
  gen_qobjectdefs_types.QMetaObjectConnection(
    h: QObject_connectRawSlot(
      sender.h,
      cstring(senderFunc),
      context.h,
      cast[int](addr(tmp[])),
      nil,
      connectionType,
      sender.metaObject().h,
    )
  )
