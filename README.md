# AZ-204 Weather Test API

A minimal .NET 8 Web API project designed for AZ-204 certification study, focusing on Azure deployment patterns and CI/CD practices.

## Project Purpose

This project serves as a learning testbed for:
- **AZ-204 Certification Study**: Hands-on experience with Azure services and deployment
- **Docker & Azure CLI Practice**: Command-line focused container operations
- **CI/CD Pipeline Development**: Multiple deployment strategies and automation
- **Project Revival Methodology**: Ensuring projects can be restored after deletion to encourage experimentation

## Deployment Objectives

### ✅ Completed
1. **CLI-focused deployment of Container Instance** - Manual Azure Container Instance deployment via CLI

### 🔄 Planned Implementation
2. CLI-focused deployment of Container App
3. GitHub Actions deployment of Container Instance  
4. GitHub Actions deployment of Container App
5. Infrastructure as Code with Bicep templates
6. Infrastructure as Code with ARM templates

## Project Structure

```
az-204-weather-test-raw-06-24/
  Program.cs                        # Main API entry point
  Dockerfile                        # Container configuration
  *.csproj                          # Project file
  appsettings*.json                 # Configuration files
  .github/workflows/                # GitHub Actions (planned)
  infra/                            # Infrastructure templates
  scripts/                          # Deployment scripts
    manual-complete-docker-to-ci.sh   # ✅ Working ACI deployment
    build-push-image.sh               # 🔧 Needs refinement
    container-app.sh                  # 🔧 Needs refinement  
    setup-env.sh                      # 🔧 Needs refinement
  templates/
    containerapp.bicep             # 🔧 Bicep template (WIP)
  Properties/PublishProfiles/
    az204MilanJreg.pubxml          # ✅ Working publish profile
```
## Technology Stack

- **.NET 8** - Web API framework
- **Docker** - Containerization
- **Azure Container Instance** - Cloud hosting
- **Azure Container Registry** - Image storage
- **Swagger/OpenAPI** - API documentation
- **Azure CLI** - Deployment automation

## Quick Start

### Prerequisites
- .NET 8 SDK
- Docker Desktop
- Azure CLI
- Azure subscription

### Local Development
```bash
# Clone and navigate to project
cd az-204-weather-test-raw-06-24

# Restore dependencies
dotnet restore

# Run locally
dotnet run

# Access Swagger UI
# Navigate to: https://localhost:7xxx/swagger
```

### Docker Build & Test
```bash
# Build image
docker build -t weather-api .

# Run container locally
docker run -p 8080:8080 weather-api

# Test endpoint
curl http://localhost:8080/weatherforecast
```

### Azure Deployment (Container Instance)
```bash
# Use the working deployment script
chmod +x scripts/manual-complete-docker-to-ci.sh
./scripts/manual-complete-docker-to-ci.sh
```

## Deployment Status & Scripts

### ✅ Working Solutions
- **manual-complete-docker-to-ci.sh**: Complete workflow for Container Instance deployment
- **az204MilanJreg.pubxml**: Visual Studio publish profile for both Container Apps and Container Instances

### 🔧 Work in Progress
- **build-push-image.sh**: Image build and registry push (needs debugging)
- **container-app.sh**: Container Apps deployment (needs completion)  
- **setup-env.sh**: Environment setup automation (needs refinement)
- **containerapp.bicep**: Infrastructure as Code template (needs completion)

## Version Management

This project follows a milestone-based versioning approach aligned with learning objectives:

### Version Schema: `v{Major}.{Minor}.{Patch}`
- **Major**: Completion of primary deployment method (1.x = ACI, 2.x = Container Apps, etc.)
- **Minor**: Feature additions or significant script improvements
- **Patch**: Bug fixes and minor refinements

### Current Version: `v1.0.0`
- ✅ Container Instance CLI deployment completed
- ✅ Local development and Docker containerization working
- ✅ Basic API functionality implemented

### Upcoming Milestones
- `v1.1.0`: Complete remaining CLI scripts
- `v1.2.0`: Add Bicep template support  
- `v2.0.0`: Container Apps deployment
- `v3.0.0`: GitHub Actions CI/CD

## API Endpoints

| Endpoint | Method | Description |
|----------|---------|-------------|
| `/weatherforecast` | GET | Returns sample weather data |
| `/swagger` | GET | Interactive API documentation |

## Learning Notes

### Key Learnings from Container Instance Deployment
- Manual CLI deployment provides deep understanding of Azure resource creation
- Container Registry integration requires careful attention to authentication
- Resource group and naming conventions impact automation scripts

### Areas for Future Study
- Container Apps vs Container Instances trade-offs
- GitHub Actions secrets management
- Bicep template best practices
- ARM template migration strategies

## Project Revival Instructions

To restore this project after deletion:

1. **Clone Repository**: `git clone [repository-url]`
2. **Install Dependencies**: `dotnet restore`
3. **Verify Docker**: Test local container build
4. **Check Azure Resources**: Ensure resource groups and registries exist
5. **Update Scripts**: Modify environment variables in scripts as needed
6. **Test Deployment**: Use working `manual-complete-docker-to-ci.sh` script

## Troubleshooting

### Common Issues
- **Docker Build Failures**: Check Dockerfile syntax and base image availability
- **Azure CLI Authentication**: Run `az login` and verify subscription context
- **Script Permissions**: Ensure shell scripts have execute permissions (`chmod +x`)
- **Port Conflicts**: Verify local ports 7xxx and 8080 are available

### Debugging Tips
- Use `az container logs` to view Container Instance logs
- Test Docker images locally before pushing to registry
- Verify Azure resource names match script configurations

## Contributing to This Project

When updating deployment methods:
1. Test thoroughly in development environment
2. Update this README with status changes (✅ or 🔧)
3. Document any new prerequisites or configuration steps
4. Update version number following the schema above

---

**Last Updated**: [Current Date]  
**Project Status**: Active Development - Container Instance deployment completed  
**Next Milestone**: Complete remaining CLI deployment scripts