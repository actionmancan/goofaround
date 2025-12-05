#!/usr/bin/env python3
"""Initialize default configuration files for services."""
import yaml
from pathlib import Path


def create_mosquitto_config(config_dir):
    """Create default Mosquitto configuration."""
    mosquitto_dir = config_dir / "mosquitto"
    mosquitto_dir.mkdir(parents=True, exist_ok=True)
    
    config_file = mosquitto_dir / "mosquitto.conf"
    config_content = """# Mosquitto Configuration for Home Server
listener 1883
allow_anonymous true
persistence true
persistence_location /mosquitto/data/

# Logging
log_dest stdout
log_type error
log_type warning
log_type notice
log_type information

# Connection messages
connection_messages true

# Enable system topic publishing
sys_interval 10
"""
    
    config_file.write_text(config_content)
    print(f"✅ Created: {config_file}")


def create_zigbee2mqtt_config(config_dir):
    """Create default Zigbee2MQTT configuration."""
    z2m_dir = config_dir / "zigbee2mqtt"
    z2m_dir.mkdir(parents=True, exist_ok=True)
    
    config_file = z2m_dir / "configuration.yaml"
    config = {
        "homeassistant": True,
        "permit_join": False,
        "mqtt": {
            "base_topic": "zigbee2mqtt",
            "server": "mqtt://homeserver-mosquitto:1883"
        },
        "serial": {
            "port": "/dev/ttyACM0"
        },
        "advanced": {
            "log_level": "info",
            "pan_id": 6754,
            "channel": 11,
            "network_key": "GENERATE",
            "last_seen": "ISO_8601"
        },
        "frontend": {
            "port": 8080,
            "host": "0.0.0.0"
        },
        "devices": "devices.yaml",
        "groups": "groups.yaml"
    }
    
    with open(config_file, 'w') as f:
        yaml.dump(config, f, default_flow_style=False)
    
    print(f"✅ Created: {config_file}")


def create_frigate_config(config_dir):
    """Create default Frigate configuration."""
    frigate_dir = config_dir / "frigate"
    frigate_dir.mkdir(parents=True, exist_ok=True)
    
    config_file = frigate_dir / "config.yml"
    config = {
        "mqtt": {
            "host": "homeserver-mosquitto",
            "port": 1883,
            "topic_prefix": "frigate",
            "client_id": "frigate"
        },
        "detectors": {
            "cpu1": {
                "type": "cpu"
            }
        },
        "database": {
            "path": "/media/frigate/frigate.db"
        },
        "record": {
            "enabled": True,
            "retain": {
                "days": 7,
                "mode": "motion"
            }
        },
        "snapshots": {
            "enabled": True,
            "retain": {
                "default": 7
            }
        },
        "cameras": {
            "example_camera": {
                "enabled": False,
                "ffmpeg": {
                    "inputs": [
                        {
                            "path": "rtsp://admin:password@192.168.1.100:554/stream",
                            "roles": ["detect", "record"]
                        }
                    ]
                },
                "detect": {
                    "width": 1920,
                    "height": 1080,
                    "fps": 5
                },
                "objects": {
                    "track": ["person", "car", "dog", "cat"]
                }
            }
        }
    }
    
    with open(config_file, 'w') as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)
    
    print(f"✅ Created: {config_file}")
    print("⚠️  Remember to configure your cameras in config.yml")


def create_homeassistant_config(config_dir):
    """Create default Home Assistant configuration."""
    ha_dir = config_dir / "homeassistant"
    ha_dir.mkdir(parents=True, exist_ok=True)
    
    config_file = ha_dir / "configuration.yaml"
    config = {
        "default_config": {},
        "http": {
            "server_port": 8123
        },
        "mqtt": {
            "broker": "homeserver-mosquitto",
            "port": 1883,
            "discovery": True,
            "discovery_prefix": "homeassistant"
        },
        "automation": "!include automations.yaml",
        "script": "!include scripts.yaml",
        "scene": "!include scenes.yaml"
    }
    
    # Use custom YAML dump to preserve !include tags
    config_content = """# Home Assistant Configuration
default_config:

http:
  server_port: 8123

mqtt:
  broker: homeserver-mosquitto
  port: 1883
  discovery: true
  discovery_prefix: homeassistant

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml
"""
    
    config_file.write_text(config_content)
    
    # Create empty files for automations, scripts, scenes
    (ha_dir / "automations.yaml").write_text("[]")
    (ha_dir / "scripts.yaml").write_text("{}")
    (ha_dir / "scenes.yaml").write_text("[]")
    
    print(f"✅ Created: {config_file}")


def main():
    """Initialize all configuration files."""
    project_root = Path(__file__).parent.parent
    config_dir = project_root / "configs"
    
    print("🔧 Initializing configuration files...\n")
    
    create_mosquitto_config(config_dir)
    create_zigbee2mqtt_config(config_dir)
    create_frigate_config(config_dir)
    create_homeassistant_config(config_dir)
    
    print("\n✅ Configuration initialization complete!")
    print("\n📝 Next steps:")
    print("  1. Update Zigbee2MQTT serial port if needed")
    print("  2. Configure your cameras in frigate/config.yml")
    print("  3. Run 'make deploy' to start services")


if __name__ == "__main__":
    main()


