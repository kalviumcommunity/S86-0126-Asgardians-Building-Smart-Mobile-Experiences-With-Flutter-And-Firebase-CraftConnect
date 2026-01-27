# 🔧 Git Commands for Submission

## 📋 Quick Command List

```bash
# 1. Check what files changed
git status

# 2. Add all files
git add .

# 3. Commit with message
git commit -m "chore: demonstrated hot reload, debug console, and DevTools usage"

# 4. Create and switch to new branch (if not already on one)
git checkout -b sprint2-devtools-demo

# 5. Push to remote
git push origin sprint2-devtools-demo

# 6. Create PR on GitHub
# Go to GitHub → Pull Requests → New Pull Request
```

---

## 📝 Step-by-Step Guide

### Step 1: Check Status
```bash
git status
```
**What it shows:** All modified and new files

**Expected output:**
```
modified:   README.md
modified:   lib/main.dart
modified:   lib/screens/stateless_stateful_demo.dart
new file:   lib/screens/dev_tools_demo_screen.dart
new file:   DEMONSTRATION_GUIDE.md
new file:   QUICK_REFERENCE.md
new file:   VIDEO_SCRIPT.md
new file:   SUBMISSION_CHECKLIST.md
new file:   screenshots/README.md
```

---

### Step 2: Stage All Changes
```bash
git add .
```
**What it does:** Stages all your changes for commit

**Alternative (stage specific files):**
```bash
git add lib/
git add README.md
git add *.md
```

---

### Step 3: Commit Changes
```bash
git commit -m "chore: demonstrated hot reload, debug console, and DevTools usage"
```

**Alternative with detailed message:**
```bash
git commit -m "chore: demonstrated hot reload, debug console, and DevTools usage

- Created DevToolsDemoScreen with interactive demo
- Added debugPrint logging throughout app
- Updated README with comprehensive documentation
- Created demonstration guides and quick references
- Ready for video recording and submission"
```

---

### Step 4: Create Branch (if needed)

**Check current branch:**
```bash
git branch
```

**Create and switch to new branch:**
```bash
git checkout -b sprint2-devtools-demo
```

**Or if branch exists, just switch:**
```bash
git checkout sprint2-devtools-demo
```

---

### Step 5: Push to Remote

**First time pushing this branch:**
```bash
git push -u origin sprint2-devtools-demo
```

**Subsequent pushes:**
```bash
git push
```

**If you get errors about upstream:**
```bash
git push --set-upstream origin sprint2-devtools-demo
```

---

## 🎯 Complete Workflow (Copy-Paste)

```bash
# Navigate to project
cd "d:\Kalvium\SimulationDec\Sprint #2\S86-0126-Asgardians-Building-Smart-Mobile-Experiences-With-Flutter-And-Firebase-CraftConnect\craftconnect"

# Check status
git status

# Create new branch
git checkout -b sprint2-devtools-demo

# Stage all changes
git add .

# Commit
git commit -m "chore: demonstrated hot reload, debug console, and DevTools usage"

# Push
git push -u origin sprint2-devtools-demo
```

---

## 🔍 Common Issues & Fixes

### Issue 1: "Please tell me who you are"
```bash
git config user.email "your-email@example.com"
git config user.name "Your Name"
```

### Issue 2: "Permission denied"
```bash
# Make sure you're authenticated with GitHub
# Use GitHub Desktop or generate SSH key
```

### Issue 3: "Updates were rejected"
```bash
# Pull latest changes first
git pull origin main

# Resolve conflicts if any, then push
git push origin sprint2-devtools-demo
```

### Issue 4: "Branch already exists"
```bash
# Just switch to it
git checkout sprint2-devtools-demo

# Add and commit as normal
git add .
git commit -m "your message"
git push
```

---

## 📸 After Recording Video

### Add Screenshots and Video Link

1. **Add screenshots to git:**
```bash
git add screenshots/*.png
git commit -m "docs: add demonstration screenshots"
git push
```

2. **Update README with video link:**
```bash
# Edit README.md to add your video link
git add README.md
git commit -m "docs: add video demonstration link"
git push
```

---

## 🎯 Create Pull Request

### On GitHub:

1. Go to your repository on GitHub
2. Click "Pull Requests" tab
3. Click "New Pull Request"
4. Select your branch: `sprint2-devtools-demo`
5. Click "Create Pull Request"

### PR Title:
```
[Sprint-2] Hot Reload & DevTools Demonstration – Asgardians
```

### PR Description Template:
```markdown
## 🎯 Summary
Demonstrated Flutter's Hot Reload, Debug Console, and DevTools features.

## ✅ What's Included
- ✅ Interactive demo screen with Hot Reload examples
- ✅ Debug Console logging throughout app
- ✅ DevTools exploration (Widget Inspector, Performance)
- ✅ Comprehensive documentation and guides

## 📸 Screenshots
[Add your screenshots here]

## 🎥 Video Demo
**Link:** [Your video link]

## 💭 Key Learnings
Hot Reload saves hours per week, Debug Console provides visibility, DevTools enables proactive debugging and performance optimization.

Ready for review! 🚀
```

---

## 🚀 Alternative: Using GitHub Desktop

If you prefer GUI:

1. Open GitHub Desktop
2. Select your repository
3. Create new branch: `sprint2-devtools-demo`
4. Review changes in left panel
5. Write commit message: "chore: demonstrated hot reload, debug console, and DevTools usage"
6. Click "Commit to sprint2-devtools-demo"
7. Click "Push origin"
8. Click "Create Pull Request" button

---

## ✅ Verification Checklist

Before pushing:
- [ ] All files are saved
- [ ] App runs without errors: `flutter run`
- [ ] No sensitive data in commits
- [ ] Commit message is clear
- [ ] Branch name is descriptive

After pushing:
- [ ] PR is created
- [ ] Screenshots are added
- [ ] Video link is included
- [ ] Team is notified

---

## 🎓 Git Best Practices

**DO:**
- ✅ Write clear commit messages
- ✅ Commit related changes together
- ✅ Push frequently
- ✅ Create descriptive branch names

**DON'T:**
- ❌ Commit secrets or API keys
- ❌ Commit build files (already in .gitignore)
- ❌ Make huge commits with unrelated changes
- ❌ Force push to shared branches

---

**All set! Just copy and run the commands above.** 🎉
