# Quard Star
---
![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/837d30fa-7762-49dc-9170-0964fcfdc2fb/b25c336e-0c4e-46ff-aea2-2ce1ae0be6ac/image.png)

An SoC (System on Chip) incorporates various IPs (hardware) onto a single board or chip. Such boards, though small, are used in devices that require computing capabilities, such as SSDs. QEMU allows users to create virtual devices for prototyping at the beginning of designing such devices. In this study, we will create a virtual RISC-V board named Quardstar and follow the process of running Linux on it.

# Build
---
```
# Build qemu : use gcc-11 version
./build_qemu.sh

# Build firmware
./build_firmware.sh
```

# Run
---
```
run.sh
```

# Demo
https://youtu.be/0HTPDV6hVGQ?si=8wWRpD8l6PYyfQuw


