"""Unit tests for quadlet file structure and validity."""
import pytest
from pathlib import Path
import configparser


class TestQuadletFiles:
    """Test quadlet configuration files."""

    def test_quadlets_directory_exists(self, quadlets_dir):
        """Test that quadlets directory exists."""
        assert quadlets_dir.exists()
        assert quadlets_dir.is_dir()

    def test_network_quadlet_exists(self, quadlets_dir):
        """Test that network quadlet file exists."""
        network_file = quadlets_dir / "homeserver-network.network"
        assert network_file.exists()

    def test_mosquitto_quadlet_exists(self, quadlets_dir):
        """Test that mosquitto quadlet file exists."""
        mosquitto_file = quadlets_dir / "homeserver-mosquitto.container"
        assert mosquitto_file.exists()

    def test_homeassistant_quadlet_exists(self, quadlets_dir):
        """Test that homeassistant quadlet file exists."""
        ha_file = quadlets_dir / "homeserver-homeassistant.container"
        assert ha_file.exists()

    def test_frigate_quadlet_exists(self, quadlets_dir):
        """Test that frigate quadlet file exists."""
        frigate_file = quadlets_dir / "homeserver-frigate.container"
        assert frigate_file.exists()

    def test_zigbee2mqtt_quadlet_exists(self, quadlets_dir):
        """Test that zigbee2mqtt quadlet file exists."""
        z2m_file = quadlets_dir / "homeserver-zigbee2mqtt.container"
        assert z2m_file.exists()

    def test_nginx_proxy_quadlet_exists(self, quadlets_dir):
        """Test that nginx proxy quadlet file exists."""
        nginx_file = quadlets_dir / "homeserver-nginx-proxy.container"
        assert nginx_file.exists()

    def test_adguard_quadlet_exists(self, quadlets_dir):
        """Test that adguard quadlet file exists."""
        adguard_file = quadlets_dir / "homeserver-adguard.container"
        assert adguard_file.exists()


class TestQuadletStructure:
    """Test quadlet file structure and required sections."""

    def parse_quadlet(self, filepath):
        """Parse a quadlet file using configparser."""
        parser = configparser.ConfigParser()
        parser.read(filepath)
        return parser

    def test_network_has_required_sections(self, quadlets_dir):
        """Test network quadlet has required sections."""
        network_file = quadlets_dir / "homeserver-network.network"
        parser = self.parse_quadlet(network_file)
        
        assert "Network" in parser
        assert "Install" in parser
        assert parser["Network"]["NetworkName"] == "homeserver"

    def test_mosquitto_has_required_sections(self, quadlets_dir):
        """Test mosquitto quadlet has all required sections."""
        mosquitto_file = quadlets_dir / "homeserver-mosquitto.container"
        parser = self.parse_quadlet(mosquitto_file)
        
        assert "Unit" in parser
        assert "Container" in parser
        assert "Service" in parser
        assert "Install" in parser

    def test_mosquitto_has_image(self, quadlets_dir):
        """Test mosquitto quadlet specifies an image."""
        mosquitto_file = quadlets_dir / "homeserver-mosquitto.container"
        parser = self.parse_quadlet(mosquitto_file)
        
        assert "Image" in parser["Container"]
        assert "mosquitto" in parser["Container"]["Image"].lower()

    def test_mosquitto_publishes_port_1883(self, quadlets_dir):
        """Test mosquitto publishes MQTT port 1883."""
        mosquitto_file = quadlets_dir / "homeserver-mosquitto.container"
        content = mosquitto_file.read_text()
        
        assert "PublishPort=1883:1883" in content

    def test_homeassistant_has_health_check(self, quadlets_dir):
        """Test homeassistant has health check configured."""
        ha_file = quadlets_dir / "homeserver-homeassistant.container"
        content = ha_file.read_text()
        
        assert "HealthCmd" in content
        assert "HealthInterval" in content

    def test_frigate_has_shared_memory(self, quadlets_dir):
        """Test frigate has shared memory configured."""
        frigate_file = quadlets_dir / "homeserver-frigate.container"
        parser = self.parse_quadlet(frigate_file)
        
        assert "ShmSize" in parser["Container"]

    def test_all_containers_have_restart_policy(self, quadlets_dir):
        """Test all container quadlets have restart policy."""
        container_files = list(quadlets_dir.glob("*.container"))
        
        for container_file in container_files:
            parser = self.parse_quadlet(container_file)
            assert "Service" in parser
            assert "Restart" in parser["Service"]

    def test_all_containers_on_homeserver_network(self, quadlets_dir):
        """Test all containers are on homeserver network."""
        container_files = list(quadlets_dir.glob("*.container"))
        
        for container_file in container_files:
            content = container_file.read_text()
            assert "Network=homeserver.network" in content

    def test_zigbee2mqtt_depends_on_mosquitto(self, quadlets_dir):
        """Test zigbee2mqtt has dependency on mosquitto."""
        z2m_file = quadlets_dir / "homeserver-zigbee2mqtt.container"
        content = z2m_file.read_text()
        
        assert "After=homeserver-mosquitto.service" in content
        assert "Requires=homeserver-mosquitto.service" in content

    def test_homeassistant_waits_for_mosquitto(self, quadlets_dir):
        """Test homeassistant waits for mosquitto."""
        ha_file = quadlets_dir / "homeserver-homeassistant.container"
        content = ha_file.read_text()
        
        assert "After=homeserver-mosquitto.service" in content


class TestQuadletSecurity:
    """Test security settings in quadlet files."""

    def test_containers_have_volume_selinux_labels(self, quadlets_dir):
        """Test containers have SELinux labels on volumes."""
        container_files = list(quadlets_dir.glob("*.container"))
        
        for container_file in container_files:
            content = container_file.read_text()
            if "Volume=" in content:
                # Check if at least one volume has :Z or :z label
                assert ":Z" in content or ":z" in content, \
                    f"{container_file.name} should have SELinux labels on volumes"

    def test_mosquitto_runs_as_non_root(self, quadlets_dir):
        """Test mosquitto runs as non-root user."""
        mosquitto_file = quadlets_dir / "homeserver-mosquitto.container"
        parser = configparser.ConfigParser()
        parser.read(mosquitto_file)
        
        assert "User" in parser["Container"]
        assert parser["Container"]["User"] != "0"


class TestQuadletNaming:
    """Test quadlet naming conventions."""

    def test_all_quadlets_have_homeserver_prefix(self, quadlets_dir):
        """Test all quadlet files start with homeserver-."""
        quadlet_files = list(quadlets_dir.glob("homeserver-*"))
        
        assert len(quadlet_files) > 0
        for qf in quadlet_files:
            assert qf.name.startswith("homeserver-")

    def test_container_names_match_service_names(self, quadlets_dir):
        """Test container names match their service names."""
        container_files = list(quadlets_dir.glob("*.container"))
        
        for container_file in container_files:
            parser = configparser.ConfigParser()
            parser.read(container_file)
            
            container_name = parser["Container"]["ContainerName"]
            filename = container_file.stem
            
            assert filename == container_name, \
                f"Container name {container_name} should match filename {filename}"


