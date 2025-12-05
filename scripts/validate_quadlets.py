#!/usr/bin/env python3
"""Validate quadlet configuration files."""
import configparser
import sys
from pathlib import Path


def validate_quadlet(file_path):
    """Validate a single quadlet file."""
    errors = []
    
    parser = configparser.ConfigParser()
    try:
        parser.read(file_path)
    except Exception as e:
        return [f"Failed to parse: {e}"]
    
    # Check for required sections based on file type
    if file_path.suffix == ".container":
        required_sections = ["Unit", "Container", "Service", "Install"]
        for section in required_sections:
            if section not in parser:
                errors.append(f"Missing required section: {section}")
        
        # Validate Container section
        if "Container" in parser:
            if "Image" not in parser["Container"]:
                errors.append("Container section missing Image")
            if "ContainerName" not in parser["Container"]:
                errors.append("Container section missing ContainerName")
        
        # Validate Service section
        if "Service" in parser:
            if "Restart" not in parser["Service"]:
                errors.append("Service section missing Restart policy")
    
    elif file_path.suffix == ".network":
        required_sections = ["Network", "Install"]
        for section in required_sections:
            if section not in parser:
                errors.append(f"Missing required section: {section}")
    
    return errors


def main():
    """Validate all quadlet files."""
    project_root = Path(__file__).parent.parent
    quadlets_dir = project_root / "quadlets"
    
    if not quadlets_dir.exists():
        print(f"ERROR: Quadlets directory not found: {quadlets_dir}")
        sys.exit(1)
    
    all_errors = {}
    
    # Find all quadlet files
    for quadlet_file in quadlets_dir.glob("*.{container,network,volume}"):
        if not quadlet_file.is_file():
            continue
        
        errors = validate_quadlet(quadlet_file)
        if errors:
            all_errors[quadlet_file.name] = errors
    
    # Report results
    if all_errors:
        print("❌ Validation FAILED\n")
        for filename, errors in all_errors.items():
            print(f"{filename}:")
            for error in errors:
                print(f"  - {error}")
            print()
        sys.exit(1)
    else:
        print("✅ All quadlet files are valid")
        sys.exit(0)


if __name__ == "__main__":
    main()


