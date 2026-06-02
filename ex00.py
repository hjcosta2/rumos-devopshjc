- name: Configure Git and Push
        run: |
          git config --global user.name "github-actions[bot]"
          git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
          
          git add sample.txt
          git commit -m "docs: add sample.txt via native git"
          git push origin main
