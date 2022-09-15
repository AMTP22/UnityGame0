using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class testScript1 : MonoBehaviour
{
    private Rigidbody2D _rb;

    [SerializeField] private int _playerHealth = 100;
    private float _playerSpeed = 4.6f;
    private bool _isGrounded = true;
    private string _playerName = "Player 1";
    private Vector2 _playerPosition = new Vector2(-5f, 0f);

    private void Start()
    {
        gameObject.transform.position = _playerPosition;
        _rb = gameObject.GetComponent<Rigidbody2D>();
        _rb.gravityScale = 0;
    }



}
