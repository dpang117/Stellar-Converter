import unittest
import requests

BASE_URL = "http://127.0.0.1:5000"

class TestCurrencyAPI(unittest.TestCase):
    def test_fiat_to_fiat(self):
        response = requests.get(f"{BASE_URL}/convert?from=USD&to=EUR&amount=100")
        data = response.json()
        self.assertIn("converted_amount", data)

    def test_fiat_to_crypto(self):
        response = requests.get(f"{BASE_URL}/convert?from=USD&to=bitcoin&amount=100")
        data = response.json()
        self.assertIn("converted_amount", data)

    def test_crypto_to_crypto(self):
        response = requests.get(f"{BASE_URL}/convert?from=bitcoin&to=ethereum&amount=1")
        data = response.json()
        self.assertIn("converted_amount", data)

    def test_invalid_request(self):
        response = requests.get(f"{BASE_URL}/convert?from=AAA&to=BBB&amount=100")
        self.assertEqual(response.status_code, 400)

if __name__ == "__main__":
    unittest.main()
