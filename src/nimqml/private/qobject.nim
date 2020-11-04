let qObjectStaticMetaObjectInstance = newQObjectMetaObject()

proc staticMetaObject*(c: type QObject): QMetaObject =
  ## Return the metaObject of QObject
  qObjectStaticMetaObjectInstance

proc staticMetaObject*(self: QObject): QMetaObject =
  ## Return the metaObject of QObject
  qObjectStaticMetaObjectInstance

proc objectName*(self: QObject): string =
  ## Return the QObject name
  var str = dos_qobject_objectName(self.vptr)
  result = $str
  dos_chararray_delete(str)

proc `objectName=`*(self: QObject, name: string) =
  ## Sets the Qobject name
  dos_qobject_setObjectName(self.vptr, name.cstring)

method metaObject*(self: QObject): QMetaObject {.base.} =
  ## Return the metaObject
  QObject.staticMetaObject

proc emit*(qobject: QObject, signalName: string, arguments: openarray[QVariant] = []) =
  ## Emit the signal with the given name and values
  var dosArguments: seq[DosQVariant] = @[]
  for argument in arguments:
    dosArguments.add(argument.vptr)
  let dosNumArguments = dosArguments.len.cint
  let dosArgumentsPtr: ptr DosQVariant = if dosArguments.len > 0: dosArguments[0].unsafeAddr else: nil
  dos_qobject_signal_emit(qobject.vptr, signalName.cstring, dosNumArguments, cast[ptr DosQVariantArray](dosArgumentsPtr))

method onSlotCalled*(self: QObject, slotName: string, arguments: openarray[QVariant]) {.base.} =
  ## Called from the dotherside library when a slot is called from Qml.
  discard()

proc burnMem*(p: pointer, size: Natural) =
  var sp {.volatile.} = cast[ptr byte](p)
  var c = size
  if not isNil(sp):
    zeroMem(p, size)
    while c > 0:
      sp[] = 0
      sp = cast[ptr byte](cast[uint](sp) + 1)
      dec(c)

proc burnArray*[T](a: var openarray[T]) {.inline.} =
  if len(a) > 0:
    burnMem(addr a[0], len(a) * sizeof(T))

template burnMem*[T](a: var seq[T]) =
  burnArray(a)

template burnMem*[A, B](a: var array[A, B]) =
  burnArray(a)

proc burnMem*[T](a: var T) {.inline.} =
  burnMem(addr a, sizeof(T))

proc qobjectCallback(qobjectPtr: pointer, slotNamePtr: DosQVariant, dosArgumentsLength: cint, dosArguments: ptr DosQVariantArray) {.cdecl, exportc.} =
  ## Called from the dotherside library for invoking a slot
  let qobject = cast[QObject](qobjectPtr)
  GC_ref(qobject)
  # Retrieve slot name
  let slotName = newQVariant(slotNamePtr, Ownership.Clone) # Don't take ownership but clone
  defer: slotName.delete
  # Retrieve arguments
  var arguments = toQVariantSequence(dosArguments, dosArgumentsLength, Ownership.Clone) # Don't take ownership but clone
  defer:
    arguments.delete
    burnMem(arguments)
  # Forward to args to the slot
  
  qobject.onSlotCalled(slotName.stringVal, arguments)
  # Update the slot return value
  dos_qvariant_assign(dosArguments[0], arguments[0].vptr)
  GC_unref(qobject)

proc setup*(self: QObject) =
  ## Initialize a new QObject
  self.owner = true
  self.vptr = dos_qobject_create(addr(self[]), self.metaObject.vptr, qobjectCallback)


proc delete*(self: QObject) =
  ## Delete a QObject
  if not self.owner or self.vptr.isNil:
    return
  dos_qobject_delete(self.vptr)
  self.vptr.resetToNil

proc newQObject*(): QObject =
  ## Create a new QObject
  new(result, delete)
  result.setup()

proc vptr*(self: QObject): DosQObject =
  result = self.vptr

proc signalConnect*(sender: QObject, signal: string, receiver: QObject, slot: string, signalType: int = 0) =
  dos_qobject_signal_connect(sender.vptr, ("2" & signal).cstring, receiver.vptr, ("1" & slot).cstring, signalType.cint)