# CUDA / GPU profile
Match: cuda, gpu, kernel, nvcc, `.cu`/`.cuh` files, CMake with CUDA, thrust, cub,
cutlass, nsight, "compute cluster", A100/H100, triton (GPU).

## Commands
```bash
# Build (prefer CMake if CMakeLists.txt exists, else nvcc directly)
cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
# or: nvcc -O3 -arch=sm_90 src/kernel.cu -o build/kernel

# Test
ctest --test-dir build --output-on-failure        # or the project's harness

# Correctness checks (run these — silent memory bugs are the norm in CUDA)
compute-sanitizer --tool memcheck ./build/app      # OOB / misaligned access
compute-sanitizer --tool racecheck ./build/app     # shared-memory races

# Profile
ncu --set full -o profile ./build/app              # kernel-level (Nsight Compute)
nsys profile -o trace ./build/app                  # timeline (Nsight Systems)
```

## Rules
- code-quality.md, testing.md, code-review-graph.md (always)
- error-handling.md (host-side orchestration)
- Drop frontend.md and database.md.

## Domain rules  → .claude/rules/cuda.md  (paths: "**/*.cu", "**/*.cuh", "**/*.cuh", "kernels/**")
- Check EVERY CUDA API and kernel-launch call: wrap in a `CUDA_CHECK`-style macro;
  follow kernel launches with `cudaGetLastError()` + `cudaDeviceSynchronize()` in debug builds.
- Never leave host↔device syncs (`cudaMemcpy`, `cudaDeviceSynchronize`) inside hot loops.
- Free every `cudaMalloc`; prefer RAII wrappers / `thrust::device_vector` over raw pointers.
- Coalesce global-memory access; flag strided/divergent patterns in review.
- State the target arch (`sm_XX`) explicitly; don't assume the dev box has a GPU —
  build/profiling may run on a remote cluster (capture that in CLAUDE.md if so).
- Validate kernels against a CPU reference; assert numerical tolerance, not bit-equality.

## Permissions
Allow: `Bash(cmake *)`, `Bash(nvcc *)`, `Bash(ctest *)`, `Bash(compute-sanitizer *)`,
`Bash(ncu *)`, `Bash(nsys *)`, `Bash(make *)`, plus any cluster submit command the
user mentions (`Bash(srun *)`, `Bash(sbatch *)`).

## Gotchas
- A clean compile says nothing about correctness — encode the sanitizer + reference-check habit.
- If the user mentions a remote/cluster GPU, record the submit workflow in CLAUDE.md;
  Claude can't run kernels locally on a machine with no NVIDIA GPU.
