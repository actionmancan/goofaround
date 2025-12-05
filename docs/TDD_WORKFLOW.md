# Test-Driven Development Workflow

This project follows TDD principles. Here's how to work with the test suite.

## Philosophy

**Red → Green → Refactor**

1. **Red**: Write a failing test first
2. **Green**: Write minimal code to make it pass
3. **Refactor**: Clean up the code while keeping tests green

## Test Structure

```
tests/
├── unit/           # Fast, isolated tests
├── integration/    # Tests with dependencies
└── e2e/            # Full system tests
```

## Running Tests

### All Tests
```bash
make test
```

### By Category
```bash
# Unit tests only (fast)
make test-unit

# Integration tests
make test-integration

# End-to-end tests
make test-e2e
```

### By Marker
```bash
# Skip slow tests
pytest -m "not slow"

# Only integration tests
pytest -m integration

# Only e2e tests
pytest -m e2e
```

### With Coverage
```bash
make test-coverage
```

View the HTML report:
```bash
open htmlcov/index.html
```

## Writing Tests

### Unit Test Example

```python
"""Unit test for quadlet validation."""
import pytest


class TestQuadletValidation:
    """Test quadlet file validation."""

    def test_quadlet_has_required_sections(self, quadlets_dir):
        """Test that quadlet file has required sections."""
        # Arrange
        quadlet_file = quadlets_dir / "homeserver-mosquitto.container"
        
        # Act
        parser = configparser.ConfigParser()
        parser.read(quadlet_file)
        
        # Assert
        assert "Unit" in parser
        assert "Container" in parser
        assert "Service" in parser
```

### Integration Test Example

```python
"""Integration test for MQTT connectivity."""
import pytest
import paho.mqtt.client as mqtt


class TestMQTTIntegration:
    """Test MQTT broker integration."""

    @pytest.mark.slow
    @pytest.mark.integration
    def test_mqtt_connection(self):
        """Test connection to MQTT broker."""
        # Arrange
        client = mqtt.Client()
        connected = False
        
        def on_connect(client, userdata, flags, rc):
            nonlocal connected
            connected = (rc == 0)
        
        client.on_connect = on_connect
        
        # Act
        client.connect("localhost", 1883, 60)
        client.loop_start()
        time.sleep(2)
        client.loop_stop()
        
        # Assert
        assert connected
```

### E2E Test Example

```python
"""End-to-end test for smart home workflow."""
import pytest
import requests


class TestSmartHomeWorkflow:
    """Test complete smart home workflows."""

    @pytest.mark.e2e
    @pytest.mark.slow
    def test_light_control_workflow(self):
        """Test: Toggle light via Home Assistant."""
        # Arrange
        ha_url = "http://localhost:8123"
        
        # Act - Turn on light via Home Assistant
        response = requests.post(
            f"{ha_url}/api/services/light/turn_on",
            json={"entity_id": "light.living_room"}
        )
        
        # Assert
        assert response.status_code == 200
        
        # Verify via MQTT that command was sent
        # ... additional assertions
```

## TDD Workflow for New Features

### Example: Adding a New Service

1. **Write test first** (Red):

```python
# tests/unit/test_quadlet_files.py
def test_portainer_quadlet_exists(self, quadlets_dir):
    """Test that portainer quadlet file exists."""
    portainer_file = quadlets_dir / "homeserver-portainer.container"
    assert portainer_file.exists()
```

2. **Run test** (should fail):
```bash
pytest tests/unit/test_quadlet_files.py::TestQuadletFiles::test_portainer_quadlet_exists
```

3. **Create quadlet file** (Green):
```bash
# Create the file
touch quadlets/homeserver-portainer.container
# Add content...
```

4. **Run test again** (should pass):
```bash
pytest tests/unit/test_quadlet_files.py::TestQuadletFiles::test_portainer_quadlet_exists
```

5. **Refactor** if needed while keeping tests green

## Best Practices

### Test Naming
- Test files: `test_*.py`
- Test classes: `Test*`
- Test functions: `test_*`
- Be descriptive: `test_mosquitto_publishes_port_1883` not `test_mosquitto`

### Test Organization
```python
class TestServiceName:
    """Test description for the service."""
    
    def test_specific_behavior(self):
        """Test that specific behavior works."""
        # Arrange - Set up test conditions
        # Act - Execute the code being tested
        # Assert - Verify the results
```

### Markers
Use markers to categorize tests:

```python
@pytest.mark.slow  # For tests that take > 1 second
@pytest.mark.integration  # For tests with dependencies
@pytest.mark.e2e  # For full system tests
```

### Fixtures
Use fixtures for reusable test data:

```python
@pytest.fixture
def sample_config():
    """Return sample configuration."""
    return {
        "mqtt": {
            "host": "localhost",
            "port": 1883
        }
    }
```

## Continuous Testing

### Watch Mode
Use pytest-watch for continuous testing:

```bash
pip install pytest-watch
ptw tests/
```

### Pre-commit Hook
Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
make test-unit
```

## Coverage Goals

- **Unit tests**: 80%+ coverage
- **Integration tests**: Critical paths covered
- **E2E tests**: Major workflows covered

## Debugging Failed Tests

### Verbose Output
```bash
pytest -vv tests/path/to/test.py
```

### Show Print Statements
```bash
pytest -s tests/path/to/test.py
```

### Drop into Debugger
```bash
pytest --pdb tests/path/to/test.py
```

### Run Single Test
```bash
pytest tests/unit/test_quadlet_files.py::TestQuadletFiles::test_mosquitto_quadlet_exists
```

## Test Data

### Sample Data Location
Test fixtures are in `tests/conftest.py`

### Temporary Files
Use `tmp_path` fixture:

```python
def test_config_creation(tmp_path):
    """Test configuration file creation."""
    config_file = tmp_path / "config.yaml"
    # Test with temporary file
```

## CI/CD Integration

Tests run automatically in CI:

```yaml
# .gitlab-ci.yml
test:
  script:
    - make setup
    - make test-unit
    - make test-integration
```

## Performance Testing

### Benchmark Tests
```python
def test_performance(benchmark):
    """Test performance of operation."""
    result = benchmark(function_to_test)
    assert result is not None
```

## Common Patterns

### Testing Quadlets
```python
def test_quadlet_structure(self, quadlets_dir):
    """Test quadlet has correct structure."""
    quadlet_file = quadlets_dir / "service.container"
    parser = configparser.ConfigParser()
    parser.read(quadlet_file)
    assert "Container" in parser
    assert parser["Container"]["Image"]
```

### Testing Service Availability
```python
@pytest.mark.slow
def test_service_responds(self):
    """Test service responds to HTTP."""
    response = requests.get("http://localhost:8123")
    assert response.status_code == 200
```

### Testing MQTT Messages
```python
def test_mqtt_message(self):
    """Test MQTT message published."""
    received = []
    
    def on_message(client, userdata, msg):
        received.append(msg.payload)
    
    client = mqtt.Client()
    client.on_message = on_message
    client.connect("localhost", 1883)
    client.subscribe("test/topic")
    # ... test code
    assert len(received) > 0
```

## Resources

- [Pytest Documentation](https://docs.pytest.org/)
- [Test-Driven Development](https://testdriven.io/)
- [Python Testing Best Practices](https://realpython.com/pytest-python-testing/)


