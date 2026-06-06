# ML / model training profile
Match: training, fine-tune, pytorch, tensorflow, jax, lightning, huggingface,
transformers, "experiment", wandb, mlflow, checkpoint, dataset, dataloader, "model".

## Commands
```bash
# Train
python train.py --config configs/base.yaml --seed 0
# Evaluate
python eval.py --ckpt checkpoints/best.pt
# Track / inspect
mlflow ui            # or: wandb login && wandb sync
tensorboard --logdir runs/
# Test the non-model code (data, metrics, utils)
pytest tests/
```

## Rules
- code-quality.md, testing.md, code-review-graph.md (always)
- error-handling.md (data/training pipeline)
- Drop frontend.md.

## Domain rules  → .claude/rules/ml-training.md  (paths: "train*.py", "**/training/**", "**/models/**", "**/data/**", "configs/**")
- Determinism: seed python/numpy/framework RNGs and log the seed; record git SHA + config with every run so a result is reproducible.
- No data leakage: split train/val/test BEFORE any fitting (scalers, vocab, feature stats fit on train only). Flag any transform fit on the full dataset.
- Checkpoint frequently and resumably; never let a long run depend on staying alive. Save optimizer + scheduler + step, not just weights.
- Config-driven, not hardcoded: hyperparameters live in config files, not literals scattered in code.
- Log metrics to a tracker (wandb/mlflow/tensorboard), not stdout; capture train AND val to catch overfitting.
- Validate data shapes/dtypes/`NaN`s at the dataloader boundary — fail fast on bad batches.
- Pin dependency + CUDA versions; training silently changes behavior across versions.

## Permissions
Allow: `Bash(python train.py *)`, `Bash(python eval.py *)`, `Bash(pytest *)`,
`Bash(mlflow *)`, `Bash(wandb *)`, `Bash(tensorboard *)`, plus cluster submit
commands if mentioned (`Bash(srun *)`, `Bash(sbatch *)`).

## Gotchas
- A loss that goes down is not success — check the eval metric on a held-out split.
- The most common silent bug is leakage; treat the split boundary as sacred.
- Don't commit checkpoints/datasets to git; reference an artifact store or path.
