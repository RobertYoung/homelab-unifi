# Device Enrollment

This guide explains how to enroll a new UniFi device to the controller.

## Prerequisites

- SSH access to the device
- Access to the UniFi Console to retrieve the device password

## Steps

1. **Get the device password** from the UniFi Console

2. **SSH into the device**:
   ```bash
   ssh iamrobertyoung@<DEVICE_IP>
   ```
   Enter the password retrieved from the UniFi Console when prompted.

3. **Set the inform URL** to point to the controller:
   ```bash
   set-inform http://10.0.20.63:8080/inform
   ```

4. **Verify enrollment** in the UniFi Console - the device should transition to a "Ready" state

## Troubleshooting

- If the device doesn't appear, ensure it can reach the controller IP on port 8080
- Re-run the `set-inform` command if the device was previously adopted by another controller
