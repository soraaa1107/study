from github import Github

# --- 設定 ---
# GitHub Personal Access Token
GITHUB_TOKEN = "YOUR_GITHUB_PERSONAL_ACCESS_TOKEN"

# 組織名
ORGANIZATION_NAME = "your-organization-name"

# 移行元リポジトリ名
SOURCE_REPO_NAME = "source-repository-name"

# 移行先リポジトリ名
DESTINATION_REPO_NAME = "destination-repository-name"

# --- スクリプト本体 ---
def migrate_issues():
    g = Github(GITHUB_TOKEN)
    org = g.get_organization(ORGANIZATION_NAME)
    source_repo = org.get_repo(SOURCE_REPO_NAME)
    destination_repo = org.get_repo(DESTINATION_REPO_NAME)

    print(f"'{SOURCE_REPO_NAME}' から '{DESTINATION_REPO_NAME}' へIssueを移行します...")

    issues_to_migrate = source_repo.get_issues(state='open') # 'open' または 'all' など適宜変更

    for issue in issues_to_migrate:
        # Pull RequestはIssueとして扱われる場合があるのでスキップ
        if issue.pull_request:
            print(f"  - PR #{issue.number} '{issue.title}' はスキップします。")
            continue

        print(f"  - Issue #{issue.number} '{issue.title}' を移行中...")

        # Issueの本文に元Issueへのリンクを追加 (任意)
        body = f"Original Issue: {issue.html_url}\n\n{issue.body if issue.body else ''}"

        # ラベルのリストを作成
        labels = [label.name for label in issue.labels]

        # 新しいIssueを作成
        try:
            new_issue = destination_repo.create_issue(
                title=issue.title,
                body=body,
                labels=labels,
                assignees=[assignee.login for assignee in issue.assignees] if issue.assignees else [],
                milestone=destination_repo.get_milestone(issue.milestone.title) if issue.milestone else None
            )
            print(f"    -> 新しいIssue #{new_issue.number} を '{DESTINATION_REPO_NAME}' に作成しました。")

            # コメントを移行
            for comment in issue.get_comments():
                new_issue.create_comment(f"**コメント (by {comment.user.login} at {comment.created_at}):**\n{comment.body}")
            if issue.get_comments().totalCount > 0:
                print(f"    -> {issue.get_comments().totalCount} 件のコメントを移行しました。")

            # 元のIssueをクローズ (任意)
            # issue.edit(state='closed')
            # print(f"    -> 元のIssue #{issue.number} をクローズしました。")

        except Exception as e:
            print(f"    -> Issue #{issue.number} の移行中にエラーが発生しました: {e}")

    print("--- Issueの移行が完了しました ---")

if __name__ == "__main__":
    migrate_issues()
