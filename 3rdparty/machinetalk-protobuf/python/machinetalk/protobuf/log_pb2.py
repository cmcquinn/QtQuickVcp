# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: machinetalk/protobuf/log.proto

import sys
_b=sys.version_info[0]<3 and (lambda x:x) or (lambda x:x.encode('latin1'))
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database
from google.protobuf import descriptor_pb2
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


from machinetalk.protobuf import nanopb_pb2 as machinetalk_dot_protobuf_dot_nanopb__pb2
from machinetalk.protobuf import types_pb2 as machinetalk_dot_protobuf_dot_types__pb2


DESCRIPTOR = _descriptor.FileDescriptor(
  name='machinetalk/protobuf/log.proto',
  package='machinetalk',
  syntax='proto2',
  serialized_pb=_b('\n\x1emachinetalk/protobuf/log.proto\x12\x0bmachinetalk\x1a!machinetalk/protobuf/nanopb.proto\x1a machinetalk/protobuf/types.proto\"\x8a\x01\n\nLogMessage\x12&\n\x06origin\x18\n \x02(\x0e\x32\x16.machinetalk.MsgOrigin\x12\x0b\n\x03pid\x18\x14 \x02(\x05\x12$\n\x05level\x18\x1e \x02(\x0e\x32\x15.machinetalk.MsgLevel\x12\x0b\n\x03tag\x18( \x02(\t\x12\x0c\n\x04text\x18\x32 \x02(\t:\x06\x92?\x03H\x90\x03')
  ,
  dependencies=[machinetalk_dot_protobuf_dot_nanopb__pb2.DESCRIPTOR,machinetalk_dot_protobuf_dot_types__pb2.DESCRIPTOR,])
_sym_db.RegisterFileDescriptor(DESCRIPTOR)




_LOGMESSAGE = _descriptor.Descriptor(
  name='LogMessage',
  full_name='machinetalk.LogMessage',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='origin', full_name='machinetalk.LogMessage.origin', index=0,
      number=10, type=14, cpp_type=8, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='pid', full_name='machinetalk.LogMessage.pid', index=1,
      number=20, type=5, cpp_type=1, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='level', full_name='machinetalk.LogMessage.level', index=2,
      number=30, type=14, cpp_type=8, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='tag', full_name='machinetalk.LogMessage.tag', index=3,
      number=40, type=9, cpp_type=9, label=2,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='text', full_name='machinetalk.LogMessage.text', index=4,
      number=50, type=9, cpp_type=9, label=2,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=_descriptor._ParseOptions(descriptor_pb2.MessageOptions(), _b('\222?\003H\220\003')),
  is_extendable=False,
  syntax='proto2',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=117,
  serialized_end=255,
)

_LOGMESSAGE.fields_by_name['origin'].enum_type = machinetalk_dot_protobuf_dot_types__pb2._MSGORIGIN
_LOGMESSAGE.fields_by_name['level'].enum_type = machinetalk_dot_protobuf_dot_types__pb2._MSGLEVEL
DESCRIPTOR.message_types_by_name['LogMessage'] = _LOGMESSAGE

LogMessage = _reflection.GeneratedProtocolMessageType('LogMessage', (_message.Message,), dict(
  DESCRIPTOR = _LOGMESSAGE,
  __module__ = 'machinetalk.protobuf.log_pb2'
  # @@protoc_insertion_point(class_scope:machinetalk.LogMessage)
  ))
_sym_db.RegisterMessage(LogMessage)


_LOGMESSAGE.has_options = True
_LOGMESSAGE._options = _descriptor._ParseOptions(descriptor_pb2.MessageOptions(), _b('\222?\003H\220\003'))
# @@protoc_insertion_point(module_scope)
