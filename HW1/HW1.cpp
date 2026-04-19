#include <iostream>
#include <vector>
#include <string>
#include <numeric>

using namespace std;

class SDFScheduler {
private:
    vector<char> actors;          // A, B, C, ...
    vector<int> q;                // repetition vector
    vector<int> prod;             // production rate on each edge

    vector<vector<int>> dp;       // minimum buffer cost
    vector<vector<int>> split;    // best split position
    vector<vector<int>> g;        // gcd of subchain

public:
    SDFScheduler(const vector<char>& actorNames,
                 const vector<int>& repetitions,
                 const vector<int>& productions)
        : actors(actorNames), q(repetitions), prod(productions) {
        int n = q.size();
        dp.assign(n, vector<int>(n, 0));
        split.assign(n, vector<int>(n, -1));
        g.assign(n, vector<int>(n, 1));
    }

    int findGCD(int i, int j) {
        int ans = 0;
        for (int k = i; k <= j; k++) {
            ans = gcd(ans, q[k]);
        }
        return ans;
    }

    void computeGCDTable() {
        int n = q.size();
        for (int i = 0; i < n; i++) {
            g[i][i] = q[i];
        }

        for (int len = 2; len <= n; len++) {
            for (int i = 0; i + len - 1 < n; i++) {
                int j = i + len - 1;
                g[i][j] = findGCD(i, j);
            }
        }
    }

    void runDP() {
        int n = q.size();
        computeGCDTable();

        for (int i = 0; i < n; i++) {
            dp[i][i] = 0;
        }

        for (int len = 2; len <= n; len++) {
            for (int i = 0; i + len - 1 < n; i++) {
                int j = i + len - 1;
                dp[i][j] = 1e9;

                for (int k = i; k < j; k++) {
                    int splitCost = (q[k] * prod[k]) / g[i][j];
                    int totalCost = dp[i][k] + dp[k + 1][j] + splitCost;

                    if (totalCost < dp[i][j]) {
                        dp[i][j] = totalCost;
                        split[i][j] = k;
                    }
                }
            }
        }
    }

    string buildSchedule(int i, int j) {
        int currentGCD = g[i][j];

        if (i == j) {
            int count = q[i] / currentGCD;
            return to_string(count) + actors[i];
        }

        int k = split[i][j];

        string left = buildSchedule(i, k);
        string right = buildSchedule(k + 1, j);

        int leftFactor = g[i][k] / currentGCD;
        int rightFactor = g[k + 1][j] / currentGCD;

        if (leftFactor > 1) {
            left = to_string(leftFactor) + "(" + left + ")";
        }

        if (rightFactor > 1) {
            right = to_string(rightFactor) + "(" + right + ")";
        }

        return left + " " + right;
    }

    void printTables() {
        int n = q.size();

        cout << "DP Cost Table:\n";
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (j < i) cout << "-\t";
                else cout << dp[i][j] << "\t";
            }
            cout << "\n";
        }

        cout << "\nSplit Table:\n";
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (j <= i) cout << "-\t";
                else cout << actors[split[i][j]] << "\t";
            }
            cout << "\n";
        }
    }

    void printResult() {
        int n = q.size();
        cout << "Minimum total buffer size = " << dp[0][n - 1] << "\n";
        cout << "Optimal single appearance schedule = " << buildSchedule(0, n - 1) << "\n";
    }
};

int main() {
    vector<char> actors = {'A','B','C','D','E','F','G','H'};

// Repetition vector (non-trivial, mixed gcd structure)
vector<int> q = {6, 9, 12, 8, 4, 10, 5, 15};

// Production rates on edges:
// A->B, B->C, C->D, D->E, E->F, F->G, G->H
vector<int> prod = {4, 6, 3, 2, 5, 2, 3};

    SDFScheduler scheduler(actors, q, prod);

    scheduler.runDP();
    scheduler.printTables();
    cout << "\n";
    scheduler.printResult();

    return 0;
}