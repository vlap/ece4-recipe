#!/usr/bin/env bash
# Quick 2-minute demo of ece4-exp

set +e  # Don't exit on errors

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════╗"
echo "║       ece4-exp: EC-Earth4 Made Easy - Quick Demo        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Step 1: List recipes
echo -e "${CYAN}📋 Step 1: What recipes are available?${NC}"
echo "$ ./ece4-exp list"
echo ""
./ece4-exp list
echo ""
read -p "Press Enter to continue..."
echo ""

# Step 2: Generate GCM experiment
echo -e "${CYAN}🚀 Step 2: Generate a coupled GCM experiment${NC}"
echo "$ ./ece4-exp generate --recipe gcm-sr.yml --sim-procs 1120 --expid demo-gcm"
echo ""
if ./ece4-exp generate --recipe gcm-sr.yml --sim-procs 1120 --expid demo-gcm -o demo-gcm.yml; then
    echo -e "${GREEN}✓ Created demo-gcm.yml${NC}"
else
    echo -e "${YELLOW}✗ Generation failed${NC}"
    exit 1
fi
echo ""
read -p "Press Enter to continue..."
echo ""

# Step 3: Check what was generated
echo -e "${CYAN}🔍 Step 3: What's in the file?${NC}"
echo ""
echo "Components:"
grep "components:" demo-gcm.yml
echo ""
echo "Grids:"
grep "grid:" demo-gcm.yml | head -2
echo ""
echo "Processor layout:"
grep -A 1 "groups:" demo-gcm.yml | head -3
echo ""
wc -l demo-gcm.yml
echo ""
read -p "Press Enter to continue..."
echo ""

# Step 4: Modify and save as custom recipe
echo -e "${CYAN}💾 Step 4: Customize and save as new recipe${NC}"
echo "$ ./ece4-exp save - Save your modifications as a reusable recipe"
echo ""
echo "Let's modify the config to run 10 legs instead of 1:"
sed -i 's/nlegs: 1/nlegs: 10/' demo-gcm.yml
echo "Changed: nlegs: 1 → nlegs: 10"
echo ""
# Rename for save command (expects {expid}_experiment.yml format)
cp demo-gcm.yml demo-gcm_experiment.yml
cp ece4_exp/demo-gcm_pristine.yml ece4_exp/demo-gcm_experiment_pristine.yml
echo "$ python3 -m ece4_exp.save_recipe_from_diff --expid demo-gcm -o my-10legs.yml"
if python3 -m ece4_exp.save_recipe_from_diff --expid demo-gcm -o my-10legs.yml 2>&1 | grep -v "^$"; then
    echo ""
    if [ -f recipes/my-10legs.yml ]; then
        echo -e "${GREEN}✓ Saved as recipes/my-10legs.yml${NC}"
        echo "Recipe content:"
        cat recipes/my-10legs.yml
    fi
fi
echo ""
read -p "Press Enter to continue..."
echo ""

# Step 5: Validate
echo -e "${CYAN}✅ Step 5: Validate the configuration${NC}"
echo "$ ./ece4-exp validate demo-gcm.yml"
echo ""
./ece4-exp validate demo-gcm.yml
echo ""
read -p "Press Enter to continue..."
echo ""

# Step 6: Ocean-only example
echo -e "${CYAN}🌊 Step 6: Ocean-only experiment (different setup)${NC}"
echo "$ ./ece4-exp generate --recipe omip-sr.yml --sim-procs 224 --expid demo-omip"
echo ""
if ./ece4-exp generate --recipe omip-sr.yml --sim-procs 224 --expid demo-omip -o demo-omip.yml 2>&1 | tail -5; then
    echo ""
    echo "Components (no atmosphere!):"
    grep "components:" demo-omip.yml
    echo -e "${GREEN}✓ Created demo-omip.yml${NC}"
fi
echo ""

echo "╔══════════════════════════════════════════════════════════╗"
echo "║                      Demo Complete!                      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}⏱️  Time: ~3 minutes${NC}"
echo -e "${GREEN}📁 Files: demo-gcm.yml (229 lines), demo-omip.yml (228 lines)${NC}"
if [ -f recipes/my-10legs.yml ]; then
    echo -e "${GREEN}📁 Recipe: recipes/my-10legs.yml (saved customization)${NC}"
fi
echo ""
echo "What you saw:"
echo "  1. List available recipes"
echo "  2. Generate coupled GCM config"
echo "  3. Inspect generated config"
echo "  4. Modify config and save as new recipe"
echo "  5. Validate config"
echo "  6. Generate ocean-only config"
echo ""
echo "Next steps:"
echo "  • Run: ./ece4-exp init-user (set your defaults)"
echo "  • Read: README.md (full documentation)"
echo "  • View: docs/presentation/ece4-exp-intro.pdf (slides)"
echo ""
echo -e "${YELLOW}Clean up: rm demo-*.yml recipes/my-*.yml ece4_exp/demo-*_pristine.yml${NC}"
echo ""
