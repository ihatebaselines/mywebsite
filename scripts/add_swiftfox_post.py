import json

new_post = {
    "slug": "swiftfox",
    "title": "SwiftFox — Inside the Multimodal Architecture with Adaptive MoE & SwiGLU",
    "date": "2026-10-30",
    "category": "AI ARCHITECTURE, MULTIMODAL",
    "excerpt": "The SwiftFox architecture has evolved through many iterations: a native multimodal language model (text + up to 3 images) built with RoPE, 2D residual patch projections, SwiGLU activations, and dynamic entropy-driven adaptive Top-K MoE routing.",
    "shortStory": "Inside SwiftFox: A deep dive into building a custom multimodal language model featuring RoPE attention, 2D residual visual patch projections, SwiGLU activations, and dynamic entropy-driven adaptive Top-K MoE routing.",
    "cover": "/images/swiftfox.png",
    "gallery": [],
    "body": [
        "The SwiftFox architecture has gone through many iterations (: and today I am not here to talk about names. Tbh, it was such a fun project that I've been working on and will definitely continue to develop. I explored and adapted several tricks that modern AI runtimes and architectures like Ollama or LLaMA have used with great success, and the core goal was building a capable, flexible, and modular **multimodal language model** completely from scratch.",
        "Essentially, the model is designed to be dual-modal: you attach a set of images (I set a hard constraint of **at most 3 images** per input context) alongside your text prompt, and the model generates text as output. The architecture works seamlessly both in pure **Text -> Text** mode and in **Image + Text -> Text** mode. But the really exciting part is how the internal machinery connects.",
        "call:SwiftFox unifies visual tokens and text tokens into a single continuous sequence, feeding them through Multi-Head Attention with Rotary Position Embeddings (RoPE) followed by a Sparse Mixture of Experts (MoE) backbone powered by SwiGLU activations and entropy-guided dynamic routing.",
        "## 1. Architectural Evolution Timeline",
        "Before reaching its current state, SwiftFox underwent several iterative redesigns. Here are the key evolutionary milestones:",
        """timeline:
2026-08 | Phase 1: Vanilla Transformer Baseline | Early experiments with a decoder-only text-to-text model, standard attention, and dense MLPs. | Baseline
2026-09 | Phase 2: Patch Ingestion & 2D Residual Block | Slicing images into 2D patches and projecting them into latent space using a residual block with 1x1 convs. | Vision
2026-09 | Phase 3: Rotary Position Embeddings (RoPE) | Migrating from absolute positional encodings to RoPE on Query and Key, enabling natural relative distance decay. | Attention
2026-10 | Phase 4: SwiGLU Activations (Tricks from Ollama / LLaMA) | Replacing traditional GELU feedforward layers with SwiGLU (Swish-Gated Linear Units) for significantly higher representational capacity. | Activations
2026-10 | Phase 5: Sparse MoE with Entropy-Driven Adaptive Top-K | Dynamic expert routing where the number of active experts K adapts on-the-fly based on each token's Shannon entropy H(x). | MoE
2026-10 | Phase 6: Dual Objective Training (Cross-Entropy + Load Balancing) | Mitigating expert collapse via an auxiliary load-balancing penalty alongside autoregressive cross-entropy. | Loss""",
        "## 2. High-Level Architecture",
        "diagram:swiftfox_flow",
        "## 3. Embeddings: From Raw Pixels to Unified Latent Space",
        "In SwiftFox, the very first step is mapping heterogeneous modalities into a shared latent representation with the same hidden dimension `d_model`.",
        "For text, the process is straightforward and fast: a classic `nn.Embedding(vocab_size, d_model)` maps token IDs into dense vectors.",
        "For images (up to 3 images per context), things get interesting. Rather than relying on a heavy, frozen feature extractor that slows down forward passes, each image is sliced into two-dimensional patches and projected through a **2D Residual Block with 1x1 convolutions** (`Conv2d(kernel_size=1, stride=1)`).",
        "call:Why a 2D Residual Block with 1x1 Convs? The 1x1 projection provides a clean linear mapping between raw image patch channels and the embedding dimension d_model, while the skip-connection (residual path) prevents gradient vanishing during backpropagation, allowing early attention layers to directly condition on raw visual signals.",
        "The resulting unified sequence that enters the backbone looks like this:",
        "```\n[IMG_1_p1] [IMG_1_p2] ... [IMG_1_pn] [IMG_2_p1] ... [TXT_1] [TXT_2] ... [TXT_M]\n```",
        "Each visual patch is treated as a continuous visual prefix token. As the unified sequence enters the attention layers, text tokens can attend directly to any visual patch.",
        """code:python:embeddings.py
import torch
import torch.nn as nn

class ResidualPatchProjector(nn.Module):
    \"\"\"Projects 2D image patches into latent space d_model using 1x1 Conv with a residual skip connection.\"\"\"
    def __init__(self, in_channels: int, d_model: int):
        super().__init__()
        self.proj = nn.Conv2d(in_channels, d_model, kernel_size=1, stride=1)
        self.norm = nn.LayerNorm(d_model)
        self.residual = nn.Conv2d(in_channels, d_model, kernel_size=1) if in_channels != d_model else nn.Identity()
        self.act = nn.SiLU()

    def forward(self, patch_x: torch.Tensor) -> torch.Tensor:
        # patch_x: (B, C, H_p, W_p)
        res = self.residual(patch_x)
        out = self.proj(patch_x)
        out = self.act(out + res)
        # Flatten into visual token sequence: (B, P, d_model)
        B, C, H, W = out.shape
        out = out.flatten(2).transpose(1, 2)
        return self.norm(out)

class SwiftFoxEmbedder(nn.Module):
    def __init__(self, vocab_size: int, in_channels: int, d_model: int):
        super().__init__()
        self.text_embed = nn.Embedding(vocab_size, d_model)
        self.image_projector = ResidualPatchProjector(in_channels, d_model)

    def forward(self, text_tokens: torch.Tensor, images: torch.Tensor | None = None) -> torch.Tensor:
        txt_emb = self.text_embed(text_tokens)  # (B, T_text, d_model)
        if images is None or images.numel() == 0:
            return txt_emb
        # Process images (up to 3 images per batch)
        img_emb = self.image_projector(images)  # (B, P_total, d_model)
        # Unified concatenation: [IMG_TOKENS, TXT_TOKENS]
        return torch.cat([img_emb, txt_emb], dim=1)""",
        "## 4. Multi-Head Attention with RoPE (Rotational Position Embedding)",
        "Once visual and text tokens are concatenated, they flow through the **Multi-Head Attention (MHA)** layers. However, learned absolute positional encodings have a well-known flaw: they do not extrapolate across varying sequence lengths and treat 2D visual coordinates and 1D word tokens as rigid, arbitrary positions.",
        "To solve this, SwiftFox adopts **RoPE (Rotational Position Encoding)**. RoPE rotates Query ($q$) and Key ($k$) vectors in 2D orthogonal planes using frequency-based rotation matrices:",
        """formula:Rotary Position Embedding (RoPE)
math:q_m = R_{\Theta, m} * W_Q * x_m,    k_n = R_{\Theta, n} * W_K * x_n
desc:The dot product <q_m, k_n> depends solely on the relative offset (m - n), naturally decaying attention as relative token distance grows.
var:R_{\Theta, m} = Orthogonal block-diagonal 2x2 rotation matrix
var:m, n = Sequence position indices for Query and Key tokens
var:\Theta = Angular frequencies \Theta_i = 10000^(-2(i-1)/d)""",
        "In a multimodal setting, this is game-changing: text tokens describing an image don't need to know the arbitrary absolute position where the image ended; the relative distance between a text token ('fox') and a visual patch showing fox ears is preserved naturally.",
        """code:python:rope_attention.py
import torch
import torch.nn as nn
import math

def apply_rotary_emb(x: torch.Tensor, freqs_cos: torch.Tensor, freqs_sin: torch.Tensor) -> torch.Tensor:
    # x: (B, H, SeqLen, HeadDim)
    x1 = x[..., 0::2]
    x2 = x[..., 1::2]
    rotated = torch.stack([-x2, x1], dim=-1).flatten(-2)
    return (x * freqs_cos) + (rotated * freqs_sin)

class SwiftFoxAttention(nn.Module):
    def __init__(self, d_model: int, num_heads: int):
        super().__init__()
        self.d_model = d_model
        self.num_heads = num_heads
        self.head_dim = d_model // num_heads
        self.q_proj = nn.Linear(d_model, d_model, bias=False)
        self.k_proj = nn.Linear(d_model, d_model, bias=False)
        self.v_proj = nn.Linear(d_model, d_model, bias=False)
        self.out_proj = nn.Linear(d_model, d_model, bias=False)

    def forward(self, x: torch.Tensor, cos: torch.Tensor, sin: torch.Tensor, mask: torch.Tensor | None = None) -> torch.Tensor:
        B, S, _ = x.shape
        q = self.q_proj(x).view(B, S, self.num_heads, self.head_dim).transpose(1, 2)
        k = self.k_proj(x).view(B, S, self.num_heads, self.head_dim).transpose(1, 2)
        v = self.v_proj(x).view(B, S, self.num_heads, self.head_dim).transpose(1, 2)
        # Apply RoPE on Query and Key vectors
        q = apply_rotary_emb(q, cos, sin)
        k = apply_rotary_emb(k, cos, sin)
        # Scaled Dot-Product Attention
        scores = torch.matmul(q, k.transpose(-2, -1)) / math.sqrt(self.head_dim)
        if mask is not None:
            scores = scores.masked_fill(mask == 0, float("-inf"))
        attn = torch.softmax(scores, dim=-1)
        out = torch.matmul(attn, v)
        out = out.transpose(1, 2).contiguous().view(B, S, self.d_model)
        return self.out_proj(out)""",
        "## 5. Mixture of Experts (MoE) with SwiGLU & Adaptive Top-K",
        "After passing through multi-head attention where each token gathers contextual cross-modal information, the sequence enters the core computation engine: the **Sparse Mixture of Experts (MoE)** block.",
        "Here, two key innovations work together:",
        "### A. SwiGLU Activations (Inspired by Ollama / LLaMA Engines)",
        "Each expert inside the MoE is not a traditional MLP with ReLU or GELU. Instead, we use **SwiGLU (Swish-Gated Linear Units)**:",
        """formula:SwiGLU Feed-Forward Unit
math:SwiGLU(x) = (x * W_gate (*) Swish(x * W_up)) * W_down
desc:The combination of multiplicative gating and Swish non-linearity yields smoother gradient flow and superior representational capacity over traditional GELU/ReLU layers.""",
        "### B. Shannon Entropy-Driven Adaptive Top-K",
        "In standard MoE architectures (such as Mixtral or Switch Transformer), every token routes to a fixed number $K$ of experts (e.g., always $K=2$).",
        "But why expend equal computational budget on a trivial token (like a comma or a common preposition) as on a dense, nuanced multimodal concept? When the router is highly confident, a single expert is plenty ($K_{min}$). When a token involves high semantic ambiguity or cross-modal synthesis, dispatching to multiple experts ($K_{max}$) unlocks extra capacity.",
        "In SwiftFox, we implement dynamic expert allocation governed by the **normalized Shannon entropy $H(x)$** of the router's probability distribution:",
        """formula:Adaptive Top-K via Shannon Entropy
math:K_adaptive(x) = K_min + floor( H(x) * (K_max - K_min) )
desc:The number of active experts dynamically scales with the semantic uncertainty of each individual token.
var:H(x) = Shannon entropy H(x) = - sum( P_i * log(P_i) ) normalized in [0, 1]
var:K_min = Minimum number of consulted experts (e.g., 1)
var:K_max = Maximum number of consulted experts (e.g., 4)
var:P_i = Softmax routing probability assigned to expert i""",
        "Each selected expert processes the token, and the layer's final output is computed as the **weighted sum** of the active experts' activations:",
        "```\ny = sum_{i in Top-K} P_tilde_i(x) * Expert_i(x)\n```",
        """code:python:adaptive_moe.py
import torch
import torch.nn as nn
import torch.nn.functional as F
import math

class SwiGLUExpert(nn.Module):
    \"\"\"Individual expert powered by SwiGLU non-linearity.\"\"\"
    def __init__(self, d_model: int, d_ff: int):
        super().__init__()
        self.w_gate = nn.Linear(d_model, d_ff, bias=False)
        self.w_up = nn.Linear(d_model, d_ff, bias=False)
        self.w_down = nn.Linear(d_ff, d_model, bias=False)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.w_down(F.silu(self.w_gate(x)) * self.w_up(x))

class AdaptiveMoELayer(nn.Module):
    def __init__(self, d_model: int, num_experts: int = 8, d_ff: int = 1024, k_min: int = 1, k_max: int = 4):
        super().__init__()
        self.num_experts = num_experts
        self.k_min = k_min
        self.k_max = k_max
        self.router = nn.Linear(d_model, num_experts, bias=False)
        self.experts = nn.ModuleList([SwiGLUExpert(d_model, d_ff) for _ in range(num_experts)])

    def forward(self, x: torch.Tensor):
        # x: (B * S, d_model)
        logits = self.router(x)
        probs = F.softmax(logits, dim=-1)
        # Compute normalized Shannon entropy H(x)
        eps = 1e-9
        entropy = -torch.sum(probs * torch.log(probs + eps), dim=-1) / math.log(self.num_experts)
        # Dynamically scale K per token
        k_adaptive = self.k_min + torch.floor(entropy * (self.k_max - self.k_min)).long()
        
        out = torch.zeros_like(x)
        for i in range(x.size(0)):
            k_cur = k_adaptive[i].clamp(self.k_min, self.k_max).item()
            topk_vals, topk_idx = torch.topk(probs[i], k=k_cur)
            topk_norm_weights = topk_vals / topk_vals.sum()
            # Weighted sum over active experts
            for w, exp_id in zip(topk_norm_weights, topk_idx):
                out[i] += w * self.experts[exp_id](x[i:i+1]).squeeze(0)
        return out, probs""",
        "## 6. Autoregressive Training & Dual Objective (L_CE + L_LB)",
        "Training SwiftFox is completely **autoregressive (Next-Token Prediction)**. On each forward pass, the model receives prefix tokens (`text[:-1]`) and is tasked with predicting targets `text[1:]` (each position predicts the next word in the sequence).",
        "However, training a Mixture of Experts without regularization quickly falls into a notorious pitfall: **expert collapse**. If one expert learns even 2% faster early in training, the router tends to route all subsequent tokens exclusively to that expert, leaving the remaining experts starved and untrained.",
        "To guarantee that workload is balanced and that every expert develops unique, specialized representations, we train with a dual loss function:",
        """formula:Dual Loss: Cross-Entropy + Load Balancing
math:L_total = L_CE + L_LB
desc:The total loss balances next-token prediction accuracy with an auxiliary penalty enforcing fair expert utilization across batches.
var:L_CE = Cross-Entropy loss over prefix tokens text[:-1] -> text[1:]
var:L_LB = \alpha * E * sum_{i=1}^E ( P_i * f_i )
var:E = Total number of experts
var:P_i = Average routing probability allocated to expert i over the batch
var:f_i = Empirical fraction of tokens dispatched to expert i""",
        "call:Intuition behind L_LB: If the router were to dump every token onto a single expert i, then P_i = 1 and f_i = 1, maximizing P_i * f_i (resulting in a heavy loss penalty). Conversely, when tokens are distributed evenly (1/E per expert), the sum is minimized, encouraging diverse specialization across the entire expert ensemble.",
        """code:python:loss_computation.py
import torch
import torch.nn.functional as F

def compute_swiftfox_loss(logits, targets, router_probs, alpha: float = 0.01):
    \"\"\"
    logits: (B, S, vocab_size)
    targets: (B, S) - ground-truth targets text[1:]
    router_probs: (Batch_Tokens, E) - routing probability distribution from router
    \"\"\"
    # 1. Autoregressive Cross-Entropy Loss
    ce_loss = F.cross_entropy(logits.view(-1, logits.size(-1)), targets.view(-1))
    
    # 2. Auxiliary Load Balancing Loss
    E = router_probs.size(-1)
    P_i = router_probs.mean(dim=0)  # Mean routing probability per expert
    
    # Empirical dispatch frequency across the current batch
    top_expert = torch.argmax(router_probs, dim=-1)
    f_i = torch.bincount(top_expert, minlength=E).float() / router_probs.size(0)
    
    # Auxiliary penalty: alpha * E * sum(P_i * f_i)
    lb_loss = alpha * E * torch.sum(P_i * f_i)
    
    total_loss = ce_loss + lb_loss
    return total_loss, ce_loss, lb_loss""",
        "## 7. What's Next for SwiftFox",
        "SwiftFox has demonstrated that a native multimodal design pairing RoPE attention with adaptive MoE routing is remarkably stable during training. Grounding visual patches directly into the shared sequence space gives the model strong spatial awareness without needing external vision encoders.",
        "Key directions currently underway for SwiftFox include:",
        """list:
- **Scaling pretraining data**: expanding high-resolution image-text paired datasets and optimizing patch data loaders.
- **4-bit Quantization & GGUF export**: packaging the model for efficient local execution (seamlessly compatible with Ollama / llama.cpp stacks).
- **Fine-tuning on targeted VQA benchmarks**: technical diagrams, scientific charts, and visual code grounding.""",
        "The project is just getting started, and future checkpoints, benchmarks, and code releases will continue to be documented publicly right here."
    ],
    "links": [
        {
            "title": "SwiftFox Project Overview",
            "url": "/projects#swift",
            "badge": "PROJECT",
            "description": "General architecture status and project details on ihatebaselines."
        },
        {
            "title": "Ollama Architecture References",
            "url": "https://github.com/ollama/ollama",
            "badge": "EXTERNAL",
            "description": "Official Ollama repository and optimizations for running compact models locally."
        }
    ]
}

data_path = "src/content/postsData.json"
with open(data_path, "r", encoding="utf-8") as f:
    posts = json.load(f)

posts = [p for p in posts if p["slug"] != "swiftfox"]
posts.insert(0, new_post)

with open(data_path, "w", encoding="utf-8") as f:
    json.dump(posts, f, indent=2, ensure_ascii=False)

print("Successfully written English SwiftFox post! Total posts:", len(posts))
