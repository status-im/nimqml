proc setupUrlSchemeEventObject(self: StatusEvent) =
  self.vptr = dos_event_create_urlSchemeEvent()

proc delete*(self: StatusEvent) =
  dos_event_delete(self.vptr)
  self.vptr.resetToNil

proc setInstance*(self: StatusEvent) =
  dos_event_set_urlSchemeEvent_instance(self.vptr)

proc newStatusUrlSchemeEventObject*(): StatusEvent =
  new(result, delete)
  result.setupUrlSchemeEventObject()
