#include <ruby.h>

VALUE SuperModule = Qnil;
VALUE SuperClass = Qnil;

void Init_super();
VALUE super_initialize(VALUE self);
VALUE get_var(VALUE self);

void Init_super() {
    SuperModule = rb_define_module("Super");
    SuperClass = rb_define_class_under(SuperModule, "Super", rb_cObject);
    rb_define_method(SuperClass, "initialize", super_initialize, 0);
    rb_define_method(SuperClass, "var", get_var, 0);
}

VALUE super_initialize(VALUE self) {
    rb_iv_set(self, "@var", rb_hash_new());
    return self;
}

VALUE get_var(VALUE self) {
    return rb_iv_get(self, "@var");
}
