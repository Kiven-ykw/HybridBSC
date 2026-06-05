# Publishing Notes

This project is prepared for the GitHub repository:

```text
https://github.com/Kiven-ykw/HybridBSC
```

## Option 1: Publish With GitHub Web

1. Create a new public repository named `HybridBSC` under `Kiven-ykw`.
2. Do not initialize it with a README, license, or `.gitignore`; these files already exist in this project.
3. Upload the contents of the `HybridBSC_GitHub_Lite/` folder. This folder keeps the code repository small and excludes bulky regenerated assets.
4. Commit the uploaded files with a message such as:

```text
Initial open-source release of HybridBSC
```

## Option 2: Publish With Git

Run these commands from the cleaned publish directory:

```bash
cd HybridBSC_GitHub
git init
git branch -M main
git add .
git commit -m "Initial open-source release of HybridBSC"
git remote add origin https://github.com/Kiven-ykw/HybridBSC.git
git push -u origin main
```

## Before Announcing

- Confirm that the selected license is acceptable for all project authors.
- Review third-party BPG redistribution terms in `THIRD_PARTY_NOTICES.md` and `bpg/README`.
- Confirm that all included images, models, and data files are allowed to be redistributed.
- After cloning, run `python prepare_demo_data.py` once to regenerate `x_train.npy` and `x_test.npy`.
- Upload large optional assets as GitHub Release files instead of committing them to the main branch.
- Add badges, project website links, or release assets later if needed.
