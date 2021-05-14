/* Distributed under MIT License
Copyright (c) 2021 Remi BERTHOLET */
#include "modhomekit.h"

#define TAG "Homekit"

// Objet classe python
typedef struct 
{
	mp_obj_base_t base;
	hap_serv_t *  service;
} Service_t;

const mp_obj_type_t Service_type;


// Get the pointer of service
hap_serv_t * Service_get_ptr(mp_obj_t self_in)
{
	hap_serv_t * result = 0;
	Service_t *self = self_in;
	if (self->base.type == &Service_type)
	{
		result = self->service;
	}
	return result;
}


// Read callback
static int Service_read_callback(hap_char_t *hc, hap_status_t *status_code, void *serv_priv, void *read_priv)
{
	*status_code = Charact_read_call(hc);
	return HAP_SUCCESS;
}


// Write callback
static int Service_write_callback(hap_write_data_t write_data[], int count, void *serv_priv, void *write_priv)
{
	int i, ret = HAP_SUCCESS;
	hap_write_data_t *write;
	for (i = 0; i < count; i++) 
	{
		write = &write_data[i];
		*(write->status) = Charact_write_call(write->hc, &(write->val));
	}
	return ret;
}


// Constructor method
STATIC mp_obj_t Service_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *all_args)
{
	mp_obj_t  result = mp_const_none;
	enum 
	{ 
		ARG_uuid,
	};
	// Constructor parameters
	static const mp_arg_t allowed_args[] = 
	{
		{ MP_QSTR_uuid,  MP_ARG_REQUIRED | MP_ARG_OBJ },
	};
	
	// Parsing parameters
	mp_arg_val_t args[MP_ARRAY_SIZE(allowed_args)];
	mp_arg_parse_all_kw_array(n_args, n_kw, all_args, MP_ARRAY_SIZE(allowed_args), allowed_args, args);

	// Check uuid
	if (args[ARG_uuid].u_obj  == mp_const_none || ! mp_obj_is_str(args[ARG_uuid].u_obj))
	{
		mp_raise_TypeError(MP_ERROR_TEXT("Bad uuid"));
	}
	else
	{
		// Alloc class instance
		Service_t *self = m_new_obj_with_finaliser(Service_t);
		if (self)
		{
			self->service = 0;
			self->base.type = &Service_type;
			result = self;
			GET_STR_DATA_LEN(args[ARG_uuid].u_obj , uuid, uuid_len);
			self->service = hap_serv_create((char*)uuid);
			hap_serv_set_priv(self->service, self);

			// Set the write callback for the service
			hap_serv_set_write_cb(self->service, Service_write_callback);

			// Set the read callback for the service (optional)
			hap_serv_set_read_cb(self->service, Service_read_callback);
		}
	}
	return result;
}


// Delete method
STATIC mp_obj_t Service_deinit(mp_obj_t self_in)
{
	Service_t *self = self_in;
	if (self->service)
	{
		hap_serv_delete(self->service);
	}
	
	return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(Service_deinit_obj, Service_deinit);


// addCharact method
STATIC mp_obj_t Service_addCharact(mp_obj_t self_in, mp_obj_t charact_in)
{
	Service_t *self = self_in;
	if (self->service)
	{
		hap_char_t * charact = Charact_get_ptr(charact_in);
		if (charact)
		{
			hap_serv_add_char(self->service, charact);
		}
		else
		{
			mp_raise_TypeError(MP_ERROR_TEXT("Not Charact type"));
		}
	}
	return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_2(Service_addCharact_obj, Service_addCharact);


// print method
STATIC void Service_print(const mp_print_t *print, mp_obj_t self_in, mp_print_kind_t kind) 
{
	ESP_LOGE(TAG, "Service_print");
}


// Methods
STATIC const mp_rom_map_elem_t Service_locals_dict_table[] = 
{
	// Delete method
	{ MP_ROM_QSTR(MP_QSTR___del__),         MP_ROM_PTR(&Service_deinit_obj) },
	{ MP_ROM_QSTR(MP_QSTR_deinit),          MP_ROM_PTR(&Service_deinit_obj) },
	{ MP_ROM_QSTR(MP_QSTR_addCharact),      MP_ROM_PTR(&Service_addCharact_obj) },
};
STATIC MP_DEFINE_CONST_DICT(Service_locals_dict, Service_locals_dict_table);


// Class definition
const mp_obj_type_t Service_type = 
{
	{ &mp_type_type },
	.name        = MP_QSTR_Service,
	.print       = Service_print,
	.make_new    = Service_make_new,
	.locals_dict = (mp_obj_t)&Service_locals_dict,
};
