// zlib License
// 
// (C) 2032 XXIV
// 
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
// 
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
// 
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.
pub const cn_result_t = extern struct {
    code: c_int,
    details: [*c]const u8,
};

pub const cn_client_t = opaque {};

pub const cn_server_t = opaque {};

pub const cn_address_type_t = enum(c_uint) {
    NONE,
    IPV4,
    IPV6
};

pub const cn_endpoint_t = extern struct {
    type: cn_address_type_t,
    port: u16,
    u: extern union {
        ipv4: [4]u8,
        ipv6: [8]u16,
    }
};

pub const cn_crypto_key_t = extern struct {
    key: [32]u8,
};

pub const cn_crypto_sign_public_t = extern struct {
    key: [32]u8,
};

pub const cn_crypto_sign_secret_t = extern struct {
    key: [64]u8,
};

pub const cn_crypto_signature_t = extern struct {
    bytes: [64]u8,
};

pub const cn_client_state_t = enum(c_int) {
    CN_CLIENT_STATE_CONNECT_TOKEN_EXPIRED         = -6,
    CN_CLIENT_STATE_INVALID_CONNECT_TOKEN         = -5,
    CN_CLIENT_STATE_CONNECTION_TIMED_OUT          = -4,
    CN_CLIENT_STATE_CHALLENGE_RESPONSE_TIMED_OUT  = -3,
    CN_CLIENT_STATE_CONNECTION_REQUEST_TIMED_OUT  = -2,
    CN_CLIENT_STATE_CONNECTION_DENIED             = -1,
    CN_CLIENT_STATE_DISCONNECTED                  = 0,
    CN_CLIENT_STATE_SENDING_CONNECTION_REQUEST    = 1,
    CN_CLIENT_STATE_SENDING_CHALLENGE_RESPONSE    = 2,
    CN_CLIENT_STATE_CONNECTED                     = 3
};

pub const cn_server_config_t = extern struct {
    application_id: u64,
    max_incoming_bytes_per_second: c_int,
    max_outgoing_bytes_per_second: c_int,
    connection_timeout: c_int,
    resend_rate: f64,
    public_key: cn_crypto_sign_public_t,
    secret_key: cn_crypto_sign_secret_t,
    user_allocator_context: ?*anyopaque,
};

pub const cn_server_event_type_t = enum(c_uint) {
    CN_SERVER_EVENT_TYPE_NEW_CONNECTION,
    CN_SERVER_EVENT_TYPE_DISCONNECTED,
    CN_SERVER_EVENT_TYPE_PAYLOAD_PACKET
};

pub const cn_server_event_t = extern struct {
    type: cn_server_event_type_t,
    u: extern union {
        new_connection: extern struct {
            client_index: c_int,
            client_id: u64,
            endpoint: cn_endpoint_t,
        },
        disconnected: extern struct {
            client_index: c_int,
        },
        payload_packet: extern struct {
            client_index: c_int,
            data: ?*anyopaque,
            size: c_int,
        },
    }
};

pub extern fn cn_endpoint_init(endpoint: [*c]cn_endpoint_t, address_and_port_string: [*c]const u8) c_int;
pub extern fn cn_endpoint_to_string(endpoint: cn_endpoint_t, buffer: [*c]u8, buffer_size: c_int) void;
pub extern fn cn_endpoint_equals(a: cn_endpoint_t, b: cn_endpoint_t) c_int;
pub extern fn cn_crypto_generate_key(...) cn_crypto_key_t;
pub extern fn cn_crypto_random_bytes(data: ?*anyopaque, byte_count: c_int) void;
pub extern fn cn_crypto_sign_keygen(public_key: [*c]cn_crypto_sign_public_t, secret_key: [*c]cn_crypto_sign_secret_t) void;
pub extern fn cn_generate_connect_token(application_id: u64, creation_timestamp: u64, client_to_server_key: [*c]const cn_crypto_key_t, server_to_client_key: [*c]const cn_crypto_key_t, expiration_timestamp: u64, handshake_timeout: u32, address_count: c_int, address_list: [*c][*c]const u8, client_id: u64, user_data: [*c]const u8, shared_secret_key: [*c]const cn_crypto_sign_secret_t, token_ptr_out: [*c]u8) cn_result_t;
pub extern fn cn_client_create(port: u16, application_id: u64, use_ipv6: bool, user_allocator_context: ?*anyopaque) ?*cn_client_t;
pub extern fn cn_client_destroy(client: ?*cn_client_t) void;
pub extern fn cn_client_connect(client: ?*cn_client_t, connect_token: [*c]const u8) cn_result_t;
pub extern fn cn_client_disconnect(client: ?*cn_client_t) void;
pub extern fn cn_client_update(client: ?*cn_client_t, dt: f64, current_time: u64) void;
pub extern fn cn_client_pop_packet(client: ?*cn_client_t, packet: [*c]?*anyopaque, size: [*c]c_int, was_sent_reliably: [*c]bool) bool;
pub extern fn cn_client_free_packet(client: ?*cn_client_t, packet: ?*anyopaque) void;
pub extern fn cn_client_send(client: ?*cn_client_t, packet: ?*const anyopaque, size: c_int, send_reliably: bool) cn_result_t;
pub extern fn cn_client_state_get(client: ?*const cn_client_t) cn_client_state_t;
pub extern fn cn_client_state_string(state: cn_client_state_t) [*c]const u8;
pub extern fn cn_client_enable_network_simulator(client: ?*cn_client_t, latency: f64, jitter: f64, drop_chance: f64, duplicate_chance: f64) void;
pub extern fn cn_client_get_packet_loss_estimate(client: ?*cn_client_t) f32;
pub extern fn cn_client_get_rtt_estimate(client: ?*cn_client_t) f32;
pub extern fn cn_client_get_incoming_kbps_estimate(client: ?*cn_client_t) f32;
pub extern fn cn_client_get_outgoing_kbps_estimate(client: ?*cn_client_t) f32;
pub extern fn cn_server_create(config: cn_server_config_t) ?*cn_server_t;
pub extern fn cn_server_destroy(server: ?*cn_server_t) void;
pub extern fn cn_server_start(server: ?*cn_server_t, address_and_port: [*c]const u8) cn_result_t;
pub extern fn cn_server_stop(server: ?*cn_server_t) void;
pub extern fn cn_server_pop_event(server: ?*cn_server_t, event: [*c]cn_server_event_t) bool;
pub extern fn cn_server_free_packet(server: ?*cn_server_t, client_index: c_int, data: ?*anyopaque) void;
pub extern fn cn_server_update(server: ?*cn_server_t, dt: f64, current_time: u64) void;
pub extern fn cn_server_disconnect_client(server: ?*cn_server_t, client_index: c_int, notify_client: bool) void;
pub extern fn cn_server_send(server: ?*cn_server_t, packet: ?*const anyopaque, size: c_int, client_index: c_int, send_reliably: bool) cn_result_t;
pub extern fn cn_server_is_client_connected(server: ?*cn_server_t, client_index: c_int) bool;
pub extern fn cn_server_set_public_ip(server: ?*cn_server_t, address_and_port: [*c]const u8) void;
pub extern fn cn_server_enable_network_simulator(server: ?*cn_server_t, latency: f64, jitter: f64, drop_chance: f64, duplicate_chance: f64) void;
pub extern fn cn_server_get_packet_loss_estimate(server: ?*cn_server_t, client_index: c_int) f32;
pub extern fn cn_server_get_rtt_estimate(server: ?*cn_server_t, client_index: c_int) f32;
pub extern fn cn_server_get_incoming_kbps_estimate(server: ?*cn_server_t, client_index: c_int) f32;
pub extern fn cn_server_get_outgoing_kbps_estimate(server: ?*cn_server_t, client_index: c_int) f32;

pub fn cn_server_config_defaults() callconv(.C) cn_server_config_t {
    var config: cn_server_config_t = undefined;
    config.application_id = 0;
    config.max_incoming_bytes_per_second = 0;
    config.max_outgoing_bytes_per_second = 0;
    config.connection_timeout = 10;
    config.resend_rate = @floatCast(f64, 0.10000000149011612);
    return config;
}

pub fn cn_is_error(arg_result: cn_result_t) callconv(.C) bool {
    var result = arg_result;
    return result.code == -@as(c_int, 1);
}

pub fn cn_error_failure(arg_details: [*c]const u8) callconv(.C) cn_result_t {
    var details = arg_details;
    var result: cn_result_t = undefined;
    result.code = -@as(c_int, 1);
    result.details = details;
    return result;
}

pub fn cn_error_success() callconv(.C) cn_result_t {
    var result: cn_result_t = undefined;
    result.code = @as(c_int, 0);
    result.details = null;
    return result;
}
