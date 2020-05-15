plugin_paths = { "/usr/share/jitsi-meet/prosody-plugins/" }

-- domain mapper options, must at least have domain base set to use the mapper
muc_mapper_domain_base = "meeting.com.vn";

turncredentials_secret = "WWPESkDAVnUXJtLN";

turncredentials = {
  { type = "stun", host = "meeting.com.vn", port = "4446" },
  { type = "turn", host = "meeting.com.vn", port = "4446", transport = "udp" },
  { type = "turns", host = "meeting.com.vn", port = "443", transport = "tcp" }
};

cross_domain_bosh = false;
consider_bosh_secure = true;

VirtualHost "meeting.com.vn"
        -- enabled = false -- Remove this line to enable this host
        authentication = "cyrus"
        -- Properties below are modified by jitsi-meet-tokens package config
        -- and authentication above is switched to "token"
        --app_id="example_app_id"
        --app_secret="example_app_secret"
        -- Assign this host a certificate for TLS, otherwise it would use the one
        -- set in the global section (if any).
        -- Note that old-style SSL on port 5223 only supports one certificate, and will always
        -- use the global one.
        ssl = {
                key = "/etc/prosody/certs/meeting.com.vn.key";
                certificate = "/etc/prosody/certs/meeting.com.vn.crt";
        }
        cyrus_application_name = "xmpp"
        speakerstats_component = "speakerstats.meeting.com.vn"
        conference_duration_component = "conferenceduration.meeting.com.vn"
        -- we need bosh
        modules_enabled = {
            "bosh";
            "pubsub";
            "ping"; -- Enable mod_ping
            "speakerstats";
            "turncredentials";
            "conference_duration";
            "auth_cyrus";
        }
        c2s_require_encryption = false

Component "conference.meeting.com.vn" "muc"
    storage = "none"
    modules_enabled = {
        "muc_meeting_id";
        "muc_domain_mapper";
        -- "token_verification";
    }
    admins = { "focus@auth.meeting.com.vn" }
    muc_room_locking = false
    muc_room_default_public_jids = true

-- internal muc component
Component "internal.auth.meeting.com.vn" "muc"
    storage = "none"
    modules_enabled = {
      "ping";
    }
    admins = { "focus@auth.meeting.com.vn", "jvb@auth.meeting.com.vn" }
    muc_room_locking = false
    muc_room_default_public_jids = true

VirtualHost "auth.meeting.com.vn"
    ssl = {
        key = "/etc/prosody/certs/auth.meeting.com.vn.key";
        certificate = "/etc/prosody/certs/auth.meeting.com.vn.crt";
    }
    authentication = "internal_plain"

Component "focus.meeting.com.vn"
    component_secret = "KH1TXL2t"

Component "speakerstats.meeting.com.vn" "speakerstats_component"
    muc_component = "conference.meeting.com.vn"

Component "conferenceduration.meeting.com.vn" "conference_duration_component"
    muc_component = "conference.meeting.com.vn"

VirtualHost "guest.meeting.com.vn"
    authentication = "anonymous"
    c2s_require_encryption = false
Component "callcontrol.meeting.com.vn" component_secret = "9bZYa6mV"
