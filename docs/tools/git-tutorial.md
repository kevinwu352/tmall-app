
## cmd

```
gcl     | git clone --recurse-submodules

gfa     | git fetch --all --prune

glg     | git log --stat
glo     | git log --oneline --decorate

gst     | git status
gss     | git status -s
gsb     | git status -sb

gaa     | git add --all

gcam    | git commit -a -m
gca!    | git commit -v -a --amend

gco     | git checkout
gcb     | git checkout -b
gcm     | git checkout $(git_main_branch)
gcd     | git checkout $(git_develop_branch)

gb      | git branch
gba     | git branch -a
gbd     | git branch -d
gbD     | git branch -D
ggsup   | git branch --set-upstream-to=origin/$(git_current_branch)

gclean  | git clean -id
```


## 配置

```
git config -l
git config --global user.name "xxx"
git config --local user.email "xxx"
```


## 分支

```
# 查看各分支最后一次提交信息
git branch -v

# 通过远程分支新建本地分支
git checkout --track origin/xxx
git checkout -b xxx origin/yyy

# 上传分支到服务器同名分支
git push origin xxx
# 上传分支到服务器另一分支
git push origin xxx:yyy

# 删除远程分支
git push origin :xxx
```


## 标签

```
# 显示标签
git tag
# 查看标签版本信息
git show xxx

# 创建含附注的标签
git tag -a xxx -m "Release xxx"
# 创建轻量级标签
git tag xxx
# 从某次提交创建标签
git tag -a xxx 9fceb02

# 上传指定标签到服务器
git push origin xxx
# 上传所有标签到服务器
git push origin --tags

# 删除标签
git tag -d xxx
# 删除远程标签
git push origin :refs/tags/xxx
```


## 樱屁

```
git cherry-pick <commitHash>
git cherry-pick <HashA> <HashB>
git cherry-pick A..B

git cherry-pick --abort
git cherry-pick --continue
```


## 其它

```
# 放到工作区
git reset --mixed HEAD^
# 放到暂存区
git reset --soft HEAD^
# 直接删除两个提交
git reset --soft HEAD~2
```
