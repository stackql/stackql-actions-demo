local project = std.extVar("GOOGLE_PROJECT");
local zone = std.extVar("GOOGLE_ZONE");
{
    project: project,
    zone: zone,
    networkInterfaces: [{"subnetwork":"https://www.googleapis.com/compute/v1/projects/stackql-demo-2/regions/australia-southeast1/subnetworks/default"}],
    disks: [{"autoDelete":true,"boot":true,"initializeParams":{"diskSizeGb":"10","sourceImage":"https://compute.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"},"mode":"READ_WRITE","type":"PERSISTENT"}],
    instances: [
        {
            name: 'actions-test-1',
            machineType: 'https://www.googleapis.com/compute/v1/projects/stackql-demo-2/zones/australia-southeast1-b/machineTypes/e2-micro',
        },
        {
            name: 'actions-test-2',
            machineType: 'https://www.googleapis.com/compute/v1/projects/stackql-demo-2/zones/australia-southeast1-b/machineTypes/f1-micro',
        },
        {
            name: 'actions-test-3',
            machineType: 'https://www.googleapis.com/compute/v1/projects/stackql-demo-2/zones/australia-southeast1-b/machineTypes/e2-micro',
        },
        {
            name: 'actions-test-4',
            machineType: 'https://www.googleapis.com/compute/v1/projects/stackql-demo-2/zones/australia-southeast1-b/machineTypes/f1-micro',
        },        
    ]
}